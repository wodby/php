<?php
header('Content-Type: application/json');
echo json_encode([
    'error' => $_FILES['file']['error'] ?? null,
    'size' => $_FILES['file']['size'] ?? null,
    'hash' => !empty($_FILES['file']['tmp_name']) ? hash_file('sha256', $_FILES['file']['tmp_name']) : null,
]);
