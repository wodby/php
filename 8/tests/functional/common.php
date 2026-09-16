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
    $test();
    echo "OK\n";
}
