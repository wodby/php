<?php

// Assertions must run even when PHP was built with zend.assertions=-1.
function verify(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

// Retry service readiness only; data assertions below are never retried.
function ready(callable $connect): mixed
{
    $deadline = microtime(true) + 90;
    do {
        try {
            return $connect();
        } catch (Exception $error) {
            usleep(500000);
        }
    } while (microtime(true) < $deadline);
    throw new RuntimeException('Service did not become ready: ' . $error->getMessage(), 0, $error);
}

function runTest(string $extension, callable $test): void
{
    echo "Testing {$extension}... ";
    // tests.sh already matched the loaded modules against php_modules/<version>, so a
    // module missing here is one with no release for this PHP version.
    if (!extension_loaded($extension)) {
        echo "skipped, not available on PHP " . PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION . "\n";
        return;
    }
    $test();
    echo "OK\n";
}
