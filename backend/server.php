<?php

/**
 * Laravel development server with CORS support for static files.
 * Used by: php -S localhost:8000 -t public server.php
 */

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// Statik fayllar uchun CORS headerlarni qo'shish
$publicPath = __DIR__ . '/public' . $uri;
if ($uri !== '/' && file_exists($publicPath) && !is_dir($publicPath)) {
    // CORS headerlarni qo'shish
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, OPTIONS');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }

    // Content-Type aniqlash
    $ext = pathinfo($publicPath, PATHINFO_EXTENSION);
    $mimeTypes = [
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'svg' => 'image/svg+xml',
        'css' => 'text/css',
        'js' => 'application/javascript',
        'json' => 'application/json',
    ];
    $mime = $mimeTypes[strtolower($ext)] ?? mime_content_type($publicPath);
    header('Content-Type: ' . $mime);
    header('Content-Length: ' . filesize($publicPath));
    header('Cache-Control: public, max-age=86400');
    readfile($publicPath);
    exit;
}

// Boshqa so'rovlarni Laravel ga yo'naltirish
require_once __DIR__ . '/public/index.php';
