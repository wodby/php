<?php
require __DIR__ . '/common.php';

runTest('brotli security update', function () {
    // The extension uses the system library; its own version does not identify the fix.
    ob_start();
    (new ReflectionExtension('brotli'))->info();
    $info = ob_get_clean();
    verify(str_contains($info, 'Brotli library => external'), 'Expected the system Brotli library');
    verify(preg_match('/Brotli library version => ([0-9.]+)/', $info, $matches) === 1,
        'Brotli library version missing');
    verify(version_compare($matches[1], '1.2.1', '>='), 'Brotli decoder predates CVE-2026-111497 fix');

    $payload = str_repeat("Brotli round trip\0", 128);
    $compressed = brotli_compress($payload);
    verify(is_string($compressed), 'Brotli compression failed');
    verify(brotli_uncompress($compressed) === $payload, 'Brotli decompression changed the payload');

    // libcurl is a separate decoder entry point and must load the fixed library too.
    $curl = curl_version();
    verify(version_compare(preg_replace('#^brotli/#', '', $curl['brotli_version'] ?? '0'), '1.2.1', '>='),
        'cURL Brotli decoder predates CVE-2026-111497 fix');
});
