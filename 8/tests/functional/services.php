<?php
require __DIR__ . '/common.php';

runTest('redis', function () {
    $redis = ready(function () {
        $client = new Redis();
        verify($client->connect('redis', 6379, 2), 'Redis connection failed');
        return $client;
    });
    verify($redis->setex('extension-test', 60, 'redis-value'), 'Redis set failed');
    verify($redis->get('extension-test') === 'redis-value', 'Redis read failed');
    verify($redis->del('extension-test') === 1, 'Redis delete failed');
    $redis->close();
});
runTest('memcached', function () {
    $client = new Memcached();
    $client->addServer('memcached', 11211);
    $client->setOption(Memcached::OPT_CONNECT_TIMEOUT, 2000);
    ready(function () use ($client) {
        verify($client->set('extension-test', ['value' => 42], 60), 'Memcached write failed');
    });
    verify($client->get('extension-test') === ['value' => 42], 'Memcached serialization round trip failed');
    verify($client->delete('extension-test'), 'Memcached delete failed');
});
runTest('amqp', function () {
    $connection = ready(function () {
        $connection = new AMQPConnection(['host' => 'rabbitmq', 'login' => 'extension', 'password' => 'extension', 'connect_timeout' => 2, 'read_timeout' => 2, 'write_timeout' => 2]);
        $connection->connect();
        verify($connection->isConnected(), 'AMQP connection failed');
        return $connection;
    });
    $channel = new AMQPChannel($connection);
    $queue = new AMQPQueue($channel);
    $queue->setFlags(AMQP_EXCLUSIVE | AMQP_AUTODELETE);
    $queue->declareQueue();
    $exchange = new AMQPExchange($channel);
    $exchange->publish('amqp-value', $queue->getName());
    $message = ready(function () use ($queue) {
        $message = $queue->get();
        verify($message instanceof AMQPEnvelope, 'AMQP message not delivered');
        return $message;
    });
    verify($message->getBody() === 'amqp-value', 'AMQP payload changed');
    $queue->ack($message->getDeliveryTag());
    verify($queue->get() === null, 'AMQP queue was not drained');
    $queue->delete();
    $connection->disconnect();
});
runTest('mongodb', function () {
    $manager = new MongoDB\Driver\Manager('mongodb://mongodb:27017/?serverSelectionTimeoutMS=2000&connectTimeoutMS=2000&socketTimeoutMS=5000');
    ready(fn() => $manager->executeCommand('admin', new MongoDB\Driver\Command(['ping' => 1])));
    $bulk = new MongoDB\Driver\BulkWrite();
    $id = $bulk->insert(['value' => 'mongodb-value', 'nested' => ['answer' => 42]]);
    verify($manager->executeBulkWrite('extension_test.values', $bulk)->getInsertedCount() === 1, 'MongoDB insert failed');
    $document = $manager->executeQuery('extension_test.values', new MongoDB\Driver\Query(['_id' => $id]))->toArray()[0];
    verify($document->value === 'mongodb-value' && $document->nested->answer === 42, 'MongoDB BSON round trip failed');
    $bulk = new MongoDB\Driver\BulkWrite();
    $bulk->delete(['_id' => $id]);
    verify($manager->executeBulkWrite('extension_test.values', $bulk)->getDeletedCount() === 1, 'MongoDB delete failed');
});
runTest('rdkafka', function () {
    $config = new RdKafka\Conf();
    $config->set('bootstrap.servers', 'kafka:9092');
    $config->set('message.timeout.ms', '15000');
    $delivered = false;
    $config->setDrMsgCb(function ($producer, $message) use (&$delivered) {
        verify($message->err === RD_KAFKA_RESP_ERR_NO_ERROR, 'Kafka delivery failed: ' . $message->errstr());
        $delivered = true;
    });
    $producer = new RdKafka\Producer($config);
    ready(fn() => $producer->getMetadata(true, null, 2000));
    $name = 'extension-test-' . bin2hex(random_bytes(6));
    $topic = $producer->newTopic($name);
    $topic->produce(0, 0, 'kafka-value', 'test-key');
    verify($producer->flush(20000) === RD_KAFKA_RESP_ERR_NO_ERROR && $delivered, 'Kafka did not confirm delivery');
    $config = new RdKafka\Conf();
    $config->set('bootstrap.servers', 'kafka:9092');
    $config->set('group.id', $name);
    $config->set('enable.auto.commit', 'false');
    $consumer = new RdKafka\KafkaConsumer($config);
    $consumer->assign([new RdKafka\TopicPartition($name, 0, RD_KAFKA_OFFSET_BEGINNING)]);
    $message = $consumer->consume(20000);
    verify($message->err === RD_KAFKA_RESP_ERR_NO_ERROR, 'Kafka consume failed: ' . $message->errstr());
    verify($message->payload === 'kafka-value' && $message->key === 'test-key', 'Kafka payload/key changed');
    $consumer->close();
});
runTest('smbclient', function () {
    $state = smbclient_state_new();
    verify(smbclient_option_set($state, SMBCLIENT_OPT_TIMEOUT, 2000), 'SMB timeout configuration failed');
    verify(smbclient_state_init($state, null, 'extension', 'extension'), 'SMB initialization failed');
    ready(function () use ($state) {
        $dir = @smbclient_opendir($state, 'smb://samba/test');
        verify($dir !== false, 'SMB share unavailable');
        smbclient_closedir($state, $dir);
    });
    $path = 'smb://samba/test/extension-test.txt';
    $file = smbclient_open($state, $path, 'w');
    verify($file !== false && smbclient_write($state, $file, 'smb-value') === 9, 'SMB write failed');
    verify(smbclient_close($state, $file), 'SMB close failed');
    $file = smbclient_open($state, $path, 'r');
    verify($file !== false && smbclient_read($state, $file, 1024) === 'smb-value', 'SMB read failed');
    smbclient_close($state, $file);
    verify(smbclient_unlink($state, $path), 'SMB delete failed');
    smbclient_state_free($state);
});

// SQL Server's Linux container is supported only on x86-64; never emulate it in CI.
if (php_uname('m') !== 'x86_64') {
    echo "SKIP sqlsrv and pdo_sqlsrv integration: SQL Server container requires amd64 (module/version checks still run)\n";
    exit(0);
}
runTest('sqlsrv', function () {
    $connection = ready(function () {
        $connection = sqlsrv_connect('sqlserver', ['UID' => 'sa', 'PWD' => 'Extension_Test123!', 'TrustServerCertificate' => true, 'LoginTimeout' => 2]);
        verify($connection !== false, 'SQL Server connection failed: ' . json_encode(sqlsrv_errors()));
        return $connection;
    });
    verify(sqlsrv_query($connection, 'CREATE TABLE #extension_test (id int, value nvarchar(100))') !== false, 'SQLSRV create failed');
    verify(sqlsrv_query($connection, 'INSERT INTO #extension_test VALUES (?, ?)', [42, 'sqlsrv-value']) !== false, 'SQLSRV parameterized insert failed');
    $statement = sqlsrv_query($connection, 'SELECT id, value FROM #extension_test');
    verify($statement !== false, 'SQLSRV select failed');
    verify(sqlsrv_fetch_array($statement, SQLSRV_FETCH_ASSOC) === ['id' => 42, 'value' => 'sqlsrv-value'], 'SQLSRV row changed');
    sqlsrv_free_stmt($statement);
    sqlsrv_close($connection);
});
runTest('pdo_sqlsrv', function () {
    $pdo = ready(fn() => new PDO('sqlsrv:Server=sqlserver;TrustServerCertificate=1;LoginTimeout=2', 'sa', 'Extension_Test123!', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]));
    $pdo->exec('CREATE TABLE #extension_test (id int, value nvarchar(100))');
    $statement = $pdo->prepare('INSERT INTO #extension_test VALUES (?, ?)');
    verify($statement->execute([42, 'pdo-value']), 'PDO SQLSRV parameterized insert failed');
    $row = $pdo->query('SELECT id, value FROM #extension_test')->fetch(PDO::FETCH_ASSOC);
    verify((int) $row['id'] === 42 && $row['value'] === 'pdo-value', 'PDO SQLSRV row changed');
});
