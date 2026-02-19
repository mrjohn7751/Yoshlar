<?php

use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\FaceCompareController;
use App\Http\Controllers\Api\OfficerController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\RegionController;
use App\Http\Controllers\Api\YouthController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

// Debug: bazadagi photo qiymatlarini tekshirish (vaqtinchalik)
Route::get('/debug/photos', function () {
    $youths = \App\Models\Youth::select('id', 'full_name', 'photo')
        ->latest()->limit(20)->get()
        ->map(fn($y) => [
            'id' => $y->id,
            'name' => $y->full_name,
            'photo_raw' => $y->photo,
            'photo_type' => gettype($y->photo),
            'photo_is_null' => $y->photo === null,
            'has_slash' => $y->photo ? str_contains((string)$y->photo, '/') : false,
        ]);

    $officers = \App\Models\Officer::select('id', 'full_name', 'photo')
        ->latest()->limit(20)->get()
        ->map(fn($o) => [
            'id' => $o->id,
            'name' => $o->full_name,
            'photo_raw' => $o->photo,
            'photo_type' => gettype($o->photo),
            'photo_is_null' => $o->photo === null,
            'has_slash' => $o->photo ? str_contains((string)$o->photo, '/') : false,
        ]);

    // Diskdagi fayllar
    $youthFiles = Storage::disk('public')->exists('youths')
        ? Storage::disk('public')->files('youths')
        : [];
    $officerFiles = Storage::disk('public')->exists('officers')
        ? Storage::disk('public')->files('officers')
        : [];

    return response()->json([
        'youths_db' => $youths,
        'officers_db' => $officers,
        'youth_files_on_disk' => $youthFiles,
        'officer_files_on_disk' => $officerFiles,
        'storage_path' => storage_path('app/public'),
        'symlink_exists' => file_exists(public_path('storage')),
    ]);
});

// Auth (ochiq)
Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::post('/auth/face-reset', [PasswordResetController::class, 'faceReset'])->middleware('throttle:2,5');

// Ikkala rol uchun umumiy route'lar
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Profile (username/parol o'zgartirish va rasm yuklash - ikkala rol)
    Route::put('/auth/profile', [AuthController::class, 'updateProfile'])->middleware('throttle:sensitive');
    Route::post('/auth/profile/photo', [AuthController::class, 'updatePhoto'])->middleware('throttle:sensitive');

    // Categories & Regions (faqat o'qish)
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/regions', [RegionController::class, 'index']);

    // Youths (faqat o'qish)
    Route::get('/youths', [YouthController::class, 'index']);
    Route::get('/youths/{youth}', [YouthController::class, 'show']);

    // Officers (faqat o'qish)
    Route::get('/officers', [OfficerController::class, 'index']);
    Route::get('/officers/{officer}', [OfficerController::class, 'show']);
    Route::get('/officers/{officer}/youths', [OfficerController::class, 'youths']);

    // Activities (faqat o'qish)
    Route::get('/youths/{youth}/activities', [ActivityController::class, 'indexForYouth']);
    Route::get('/activities/{activity}', [ActivityController::class, 'show']);

    // Comments (o'qish va yozish - ikkala rol)
    Route::get('/activities/{activity}/comments', [CommentController::class, 'index']);
    Route::post('/activities/{activity}/comments', [CommentController::class, 'store']);

    // Face Compare
    Route::post('/face-compare', [FaceCompareController::class, 'compare']);
});

// Faqat rahbariyat uchun
Route::middleware(['auth:sanctum', 'rahbariyat', 'throttle:api'])->group(function () {
    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
    Route::get('/dashboard/regions', [DashboardController::class, 'regions']);
    Route::get('/dashboard/categories', [DashboardController::class, 'categories']);

    // Password reset logs
    Route::get('/password-reset-logs', [PasswordResetController::class, 'logs']);

    // Activities (barcha jarayonlar - pagination bilan)
    Route::get('/activities', [ActivityController::class, 'index']);

    // Youths (yaratish, tahrirlash, o'chirish)
    Route::post('/youths/import', [YouthController::class, 'import']);
    Route::post('/youths', [YouthController::class, 'store']);
    Route::post('/youths/{youth}', [YouthController::class, 'update']);
    Route::delete('/youths/{youth}', [YouthController::class, 'destroy']);

    // Officers (yaratish, tahrirlash, o'chirish, biriktirish)
    Route::post('/officers', [OfficerController::class, 'store']);
    Route::post('/officers/{officer}', [OfficerController::class, 'update']);
    Route::delete('/officers/{officer}', [OfficerController::class, 'destroy']);
    Route::post('/officers/{officer}/attach-youths', [OfficerController::class, 'attachYouths']);
    Route::post('/officers/{officer}/detach-youths', [OfficerController::class, 'detachYouths']);
    Route::post('/officers/{officer}/reset-password', [OfficerController::class, 'resetPassword'])->middleware('throttle:sensitive');
    Route::post('/officers/{officer}/generate-credentials', [OfficerController::class, 'generateCredentials'])->middleware('throttle:sensitive');
});

// Faqat masul uchun
Route::middleware(['auth:sanctum', 'masul', 'throttle:api'])->group(function () {
    // Youth photo (masul o'z yoshining rasmini yangilash)
    Route::post('/youths/{youth}/photo', [YouthController::class, 'updatePhoto']);

    // Activities (yaratish, rasm yuklash)
    Route::post('/youths/{youth}/activities', [ActivityController::class, 'store']);
    Route::post('/activities/{activity}/images', [ActivityController::class, 'uploadImages']);

});
