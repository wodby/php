<?php
// Reports what PHP-FPM received from Apache.
header('Content-Type: application/json');
echo json_encode([
    'script' => $_SERVER['SCRIPT_FILENAME'] ?? '',
    'route' => $_GET['route'] ?? '',
    'https' => $_SERVER['HTTPS'] ?? '',
    'authorization' => $_SERVER['HTTP_AUTHORIZATION'] ?? '',
], JSON_UNESCAPED_SLASHES), "\n";
