<?php
require __DIR__ . '/common.php';
$driver = $argv[1];
runTest($driver, function () use ($driver) {
    if ($driver === 'pcov') {
        pcov\start();
    } else {
        xdebug_start_code_coverage(XDEBUG_CC_UNUSED | XDEBUG_CC_DEAD_CODE);
    }
    $path = __DIR__ . '/coverage-fixture.php';
    verify((require $path) === 42, 'Coverage fixture failed');
    if ($driver === 'pcov') {
        pcov\stop();
        $coverage = pcov\collect();
        pcov\clear();
    } else {
        $coverage = xdebug_get_code_coverage();
        xdebug_stop_code_coverage();
    }
    verify(($coverage[$path][5] ?? null) === 1, "{$driver} did not record the executed calculation");
});
