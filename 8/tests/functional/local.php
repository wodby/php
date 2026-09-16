<?php
require __DIR__ . '/common.php';

runTest('apcu', function () {
    verify(apcu_store('extension-test', ['answer' => 42]), 'APCu store failed');
    verify(apcu_fetch('extension-test', $found) === ['answer' => 42] && $found, 'APCu round trip failed');
    verify(apcu_delete('extension-test') && !apcu_exists('extension-test'), 'APCu delete failed');
});
runTest('ast', function () {
    $tree = ast\parse_code('<?php $answer = 40 + 2;', max(ast\get_supported_versions()));
    $assignment = $tree->children[0];
    verify($assignment->kind === ast\AST_ASSIGN, 'AST assignment missing');
    verify($assignment->children['expr']->kind === ast\AST_BINARY_OP, 'AST addition missing');
});
runTest('ds', function () {
    $map = new Ds\Map(['one' => 1]);
    $map->put('two', 2);
    verify($map->get('two') === 2 && $map->sum() === 3, 'Ds map operations failed');
    $map->remove('one');
    verify(!$map->hasKey('one') && count($map) === 1, 'Ds map removal failed');
});
runTest('event', function () {
    $base = new EventBase();
    $received = '';
    $pair = EventBufferEvent::createPair($base);
    $pair[1]->setCallbacks(function ($buffer) use (&$received, $base) {
        $received .= $buffer->read(1024);
        $base->stop();
    }, null, null);
    $pair[1]->enable(Event::READ);
    $pair[0]->write('event-round-trip');
    $base->exit(2.0);
    $base->dispatch();
    verify($received === 'event-round-trip', 'Event callback/buffer round trip failed');
    $pair[0]->free();
    $pair[1]->free();
});
runTest('igbinary', function () {
    $value = ['text' => "hello\0world", 'nested' => [true, null, 42]];
    verify(igbinary_unserialize(igbinary_serialize($value)) === $value, 'Igbinary round trip failed');
});
runTest('imagick', function () {
    $image = new Imagick();
    $image->newImage(12, 8, new ImagickPixel('red'), 'png');
    $image->resizeImage(6, 4, Imagick::FILTER_LANCZOS, 1);
    $decoded = new Imagick();
    $decoded->readImageBlob($image->getImageBlob());
    verify($decoded->getImageWidth() === 6 && $decoded->getImageHeight() === 4, 'Imagick PNG round trip failed');
    verify($decoded->getImagePixelColor(0, 0)->getColor()['r'] === 255, 'Imagick pixel changed');
});
runTest('imap', function () {
    $encoded = imap_8bit("hello \xC3\xA9");
    verify(quoted_printable_decode($encoded) === "hello \xC3\xA9", 'IMAP MIME encoding failed');
    $address = imap_rfc822_parse_adrlist('Test User <user@example.com>', 'localhost')[0];
    verify($address->mailbox === 'user' && $address->host === 'example.com', 'IMAP address parsing failed');
    $path = tempnam(sys_get_temp_dir(), 'imap-test-');
    $mailbox = false;
    try {
        file_put_contents($path, "From sender@example.com Tue Sep 15 12:00:00 2026\nDate: Tue, 15 Sep 2026 12:00:00 +0000\nFrom: sender@example.com\nSubject: extension-test\n\nmail-body\n\n");
        $mailbox = imap_open($path, '', '', OP_READONLY);
        verify($mailbox !== false && imap_num_msg($mailbox) === 1, 'IMAP local mailbox open failed');
        verify(imap_headerinfo($mailbox, 1)->subject === 'extension-test', 'IMAP message header changed');
        verify(trim(imap_body($mailbox, 1)) === 'mail-body', 'IMAP message body changed');
    } finally {
        if ($mailbox !== false) {
            imap_close($mailbox);
        }
        unlink($path);
    }
});
runTest('oauth', function () {
    $base = oauth_get_sbs('GET', 'https://example.com/resource', ['b' => 'two words', 'a' => '1']);
    verify($base === 'GET&https%3A%2F%2Fexample.com%2Fresource&a%3D1%26b%3Dtwo%2520words', 'OAuth signature base string incorrect');
    verify(oauth_urlencode('a b+c') === 'a%20b%2Bc', 'OAuth percent encoding incorrect');
    $oauth = new OAuth('key', 'secret', OAUTH_SIG_METHOD_HMACSHA1);
    $oauth->setNonce('nonce');
    $oauth->setTimestamp('1234567890');
    verify($oauth->generateSignature('GET', 'https://example.com/resource', ['a' => '1']) === 'V8yL28wm8ngcSO2be2vgjA4m208=', 'OAuth HMAC-SHA1 signature incorrect');
});
runTest('opentelemetry', function () {
    $calls = [];
    verify(OpenTelemetry\Instrumentation\hook(null, 'extensionHookTarget',
        pre: function () use (&$calls) { $calls[] = 'before'; },
        post: function () use (&$calls) { $calls[] = 'after'; }), 'Hook registration failed');
    verify(extensionHookTarget(21) === 42, 'Instrumented function result changed');
    verify($calls === ['before', 'after'], 'OpenTelemetry hooks were not invoked');
});
runTest('protobuf', function () {
    $value = new Google\Protobuf\Value();
    $value->setStringValue('protobuf-round-trip');
    $copy = new Google\Protobuf\Value();
    $copy->mergeFromString($value->serializeToString());
    verify($copy->getStringValue() === 'protobuf-round-trip', 'Protobuf binary round trip failed');
    $copy->mergeFromJsonString('42');
    verify($copy->getNumberValue() === 42.0, 'Protobuf JSON decoding failed');
});
runTest('uuid', function () {
    $id = uuid_create(UUID_TYPE_RANDOM);
    verify(uuid_is_valid($id) && uuid_type($id) === UUID_TYPE_RANDOM, 'UUID generation failed');
    verify(uuid_unparse(uuid_parse($id)) === $id, 'UUID binary round trip failed');
});
runTest('xhprof', function () {
    xhprof_enable();
    extensionHookTarget(21);
    $profile = xhprof_disable();
    verify(isset($profile['main()']) && count($profile) > 1, 'XHProf did not record calls');
});
runTest('yaml', function () {
    $value = ['text' => 'hello', 'nested' => [42, true, null]];
    verify(yaml_parse(yaml_emit($value)) === $value, 'YAML round trip failed');
});

function extensionHookTarget(int $value): int
{
    return $value * 2;
}
