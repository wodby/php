<?php
require __DIR__ . '/common.php';

// Send FastCGI directly so nginx request buffering cannot hide upload progress.
function record($socket, int $type, string $data): void
{
    do {
        $chunk = substr($data, 0, 65535);
        $data = substr($data, strlen($chunk));
        $bytes = pack('CCnnCC', 1, $type, 1, strlen($chunk), 0, 0) . $chunk;
        while ($bytes !== '') {
            $written = fwrite($socket, $bytes);
            verify($written !== false && $written > 0, 'FastCGI write failed');
            $bytes = substr($bytes, $written);
        }
    } while ($data !== '');
}

function readBytes($socket, int $length): string
{
    $bytes = '';
    while (strlen($bytes) < $length) {
        $part = fread($socket, $length - strlen($bytes));
        verify($part !== false && $part !== '', 'FastCGI response ended early or timed out');
        $bytes .= $part;
    }
    return $bytes;
}

runTest('uploadprogress', function () {
    $id = bin2hex(random_bytes(16));
    $boundary = 'extension-test-boundary';
    $payload = str_repeat('upload-content-', 40000);
    $prefix = "--{$boundary}\r\nContent-Disposition: form-data; name=\"UPLOAD_IDENTIFIER\"\r\n\r\n{$id}\r\n"
        . "--{$boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\n";
    $body = $prefix . $payload . "\r\n--{$boundary}--\r\n";
    $socket = stream_socket_client('tcp://127.0.0.1:9000', $errno, $error, 5);
    verify($socket !== false, "FPM connection failed: {$error}");
    stream_set_timeout($socket, 10);
    try {
        record($socket, 1, pack('nCxxxxx', 1, 0)); // FCGI_BEGIN_REQUEST, responder role.
        $params = '';
        foreach ([
            'REQUEST_METHOD' => 'POST',
            'SCRIPT_FILENAME' => __DIR__ . '/upload-endpoint.php',
            'SCRIPT_NAME' => '/upload-endpoint.php',
            'CONTENT_TYPE' => "multipart/form-data; boundary={$boundary}",
            'CONTENT_LENGTH' => (string) strlen($body),
            'SERVER_PROTOCOL' => 'HTTP/1.1',
            'REQUEST_URI' => '/upload-endpoint.php',
        ] as $key => $value) {
            verify(strlen($key) < 128 && strlen($value) < 128, 'FastCGI parameter exceeds fixture encoding');
            $params .= chr(strlen($key)) . chr(strlen($value)) . $key . $value;
        }
        record($socket, 4, $params);
        record($socket, 4, ''); // End parameters.
        // The extension writes progress at most once per second.
        record($socket, 5, substr($body, 0, 65536));
        usleep(1100000);
        record($socket, 5, substr($body, 65536, 65536));
        $deadline = microtime(true) + 8;
        do {
            $info = uploadprogress_get_info($id);
            if (is_array($info) && $info['bytes_uploaded'] > 0) {
                break;
            }
            usleep(100000);
        } while (microtime(true) < $deadline);
        verify(is_array($info) && $info['bytes_uploaded'] > 0 && $info['bytes_uploaded'] < strlen($body), 'Upload progress was not recorded during transfer');
        verify((int) $info['bytes_total'] === strlen($body), 'Upload total size incorrect');
        record($socket, 5, substr($body, 131072));
        record($socket, 5, ''); // End request body.
        $output = '';
        do {
            $header = unpack('Cversion/Ctype/nid/nlength/Cpadding/Creserved', readBytes($socket, 8));
            $data = $header['length'] ? readBytes($socket, $header['length']) : '';
            if ($header['padding']) {
                readBytes($socket, $header['padding']);
            }
            if ($header['type'] === 6) {
                $output .= $data;
            }
        } while ($header['type'] !== 3); // FCGI_END_REQUEST.
        $result = json_decode(explode("\r\n\r\n", $output, 2)[1] ?? '', true, flags: JSON_THROW_ON_ERROR);
        verify($result === ['error' => UPLOAD_ERR_OK, 'size' => strlen($payload), 'hash' => hash('sha256', $payload)], 'Uploaded file was not received intact');
    } finally {
        fclose($socket);
    }
});
