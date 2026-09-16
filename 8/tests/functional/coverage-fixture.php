<?php
// Separate file: coverage must include execution, not just driver initialization.
function coveredCalculation(int $value): int
{
    return $value * 2;
}
return coveredCalculation(21);
