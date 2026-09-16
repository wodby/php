<?php
require __DIR__ . '/common.php';
runTest('grpc', function () {
    $server = new Grpc\Server();
    $port = $server->addHttp2Port('127.0.0.1:0');
    verify($port > 0, 'gRPC server could not bind');
    $server->start();
    $channel = new Grpc\Channel("127.0.0.1:{$port}", ['credentials' => Grpc\ChannelCredentials::createInsecure()]);
    $call = new Grpc\Call($channel, '/extension.Echo/Echo', Grpc\Timeval::now()->add(new Grpc\Timeval(5000000)));
    $call->startBatch([
        Grpc\OP_SEND_INITIAL_METADATA => [],
        Grpc\OP_SEND_MESSAGE => ['message' => 'grpc-value'],
        Grpc\OP_SEND_CLOSE_FROM_CLIENT => true,
    ]);
    $request = $server->requestCall();
    verify($request->method === '/extension.Echo/Echo', 'gRPC method changed');
    $input = $request->call->startBatch([Grpc\OP_RECV_MESSAGE => true]);
    verify($input->message === 'grpc-value', 'gRPC request payload changed');
    $request->call->startBatch([
        Grpc\OP_SEND_INITIAL_METADATA => [],
        Grpc\OP_SEND_MESSAGE => ['message' => 'reply:' . $input->message],
        Grpc\OP_SEND_STATUS_FROM_SERVER => ['code' => Grpc\STATUS_OK, 'details' => 'OK', 'metadata' => []],
        Grpc\OP_RECV_CLOSE_ON_SERVER => true,
    ]);
    $result = $call->startBatch([
        Grpc\OP_RECV_INITIAL_METADATA => true,
        Grpc\OP_RECV_MESSAGE => true,
        Grpc\OP_RECV_STATUS_ON_CLIENT => true,
    ]);
    verify($result->status->code === Grpc\STATUS_OK, 'gRPC request failed');
    verify($result->message === 'reply:grpc-value', 'gRPC response changed');
    unset($call, $request);
    $channel->close();
});
