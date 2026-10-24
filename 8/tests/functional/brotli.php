<?php
require __DIR__ . '/common.php';

runTest('brotli round trip', function () {
    $payload = str_repeat("Brotli round trip\0", 128);
    $compressed = brotli_compress($payload);
    verify(is_string($compressed), 'Brotli compression failed');
    verify(brotli_uncompress($compressed) === $payload, 'Brotli decompression changed the payload');
});
