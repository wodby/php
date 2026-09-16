<?php

// Check versions and optional build features, not just the presence of modules.
$versions = [
    'apcu' => '5.1.28',
    'amqp' => '2.2.0',
    'ast' => '1.1.3',
    'ds' => '2.0.0',
    'event' => '3.1.6',
    'grpc' => '1.83.1',
    'igbinary' => '3.2.17RC1',
    'imagick' => '3.8.1',
    'memcached' => '3.4.0',
    'mongodb' => '2.5.2',
    'oauth' => '2.0.10',
    'opentelemetry' => '1.2.1',
    'pdo_sqlsrv' => PHP_VERSION_ID < 80300 ? '5.12.0' : '5.13.3',
    'pcov' => '1.0.12',
    'protobuf' => '5.36.1',
    'rdkafka' => '6.0.5',
    'redis' => '6.3.0',
    'sqlsrv' => PHP_VERSION_ID < 80300 ? '5.12.0' : '5.13.3',
    'smbclient' => '1.1.2',
    'uploadprogress' => '2.0.2',
    'uuid' => '1.3.0',
    'xdebug' => '3.5.3',
    'xhprof' => '2.3.10',
    'yaml' => '2.3.0',
];
if (PHP_VERSION_ID >= 80400) {
    $versions['imap'] = '1.0.3';
}
foreach ($versions as $extension => $expected) {
    $actual = phpversion($extension);
    if ($actual !== $expected) {
        throw new RuntimeException("{$extension}: expected {$expected}, got " . var_export($actual, true));
    }
}

// Match the former PECL defaults, including optional serializers staying off.
$features = [
    'event' => [
        'Sockets support => enabled',
        'Extra functionality support including HTTP, DNS, and RPC => enabled',
        'OpenSSL support => enabled',
        'Thread safety support => disabled',
    ],
    'memcached' => [
        'SASL support => yes',
        'Session support => yes',
        'igbinary support => no',
        'json support => no',
        'msgpack support => no',
        'zstd support => no',
    ],
    'redis' => ['Available serializers => php, json'],
    'imap' => ['SSL Support => enabled'],
];
foreach ($features as $extension => $expectedFeatures) {
    ob_start();
    (new ReflectionExtension($extension))->info();
    $info = ob_get_clean();
    foreach ($expectedFeatures as $feature) {
        if (!str_contains($info, $feature)) {
            throw new RuntimeException("{$extension}: missing {$feature}\n{$info}");
        }
    }
}

// Source installation must preserve the PHP libraries previously installed by PECL.
require_once 'xhprof_lib/utils/xhprof_lib.php';
require_once 'xhprof_lib/utils/xhprof_runs.php';
if (!class_exists('XHProfRuns_Default') || !is_file('/usr/local/lib/php/xhprof_html/index.php')) {
    throw new RuntimeException('XHProf libraries or UI are missing');
}

echo "Extension versions and build features OK\n";
