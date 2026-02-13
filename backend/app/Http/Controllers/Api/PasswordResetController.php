<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PasswordResetLog;
use App\Models\User;
use App\Services\CredentialGenerator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PasswordResetController extends Controller
{
    public function faceReset(Request $request): JsonResponse
    {
        $request->validate([
            'username' => ['required', 'string', 'max:255'],
            'selfie' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:5120'],
        ]);

        // Foydalanuvchini topish
        $user = User::where('username', $request->username)->first();
        if (!$user || !$user->officer) {
            // Xavfsizlik: foydalanuvchi mavjudligini oshkor qilmaymiz
            return response()->json([
                'message' => "Ma'lumotlar noto'g'ri yoki mas'ul topilmadi.",
            ], 404);
        }

        $officer = $user->officer;

        if (empty($officer->photo)) {
            return response()->json([
                'message' => "Mas'ul rasmi yuklanmagan. Administrator bilan bog'laning.",
            ], 400);
        }

        $serviceUrl = config('face_service.url');
        $serviceKey = config('face_service.key');
        $timeout = config('face_service.timeout', 30);

        // Flask yuz servisiga yuborish
        try {
            $response = Http::timeout($timeout)
                ->withHeaders(['X-API-Key' => $serviceKey])
                ->attach(
                    'selfie',
                    file_get_contents($request->file('selfie')->getRealPath()),
                    'selfie.jpg'
                )->post("{$serviceUrl}/compare", [
                    'officer_photo_path' => $officer->photo,
                ]);

            if ($response->status() === 401) {
                return response()->json([
                    'message' => 'Yuz servisi konfiguratsiya xatosi.',
                ], 500);
            }

            // Soxta rasm aniqlangan
            if ($response->status() === 403) {
                $data = $response->json();
                return response()->json([
                    'message' => $data['message'] ?? 'Soxta rasm aniqlandi.',
                    'is_real' => false,
                ], 403);
            }

            if (!$response->successful()) {
                $data = $response->json();
                return response()->json([
                    'message' => $data['message'] ?? 'Yuz solishtirish xatosi.',
                ], 422);
            }

            $data = $response->json();
            $isMatch = $data['match'] ?? false;

            if (!$isMatch) {
                return response()->json([
                    'message' => $data['message'] ?? 'Yuz mos kelmadi. Qaytadan urinib ko\'ring.',
                    'similarity' => $data['similarity'] ?? 0,
                ], 403);
            }

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Yuz solishtirish servisi vaqtincha ishlamayapti.',
            ], 503);
        }

        // Yangi parol yaratish
        $credentialGenerator = new CredentialGenerator();
        $plainPassword = $credentialGenerator->generatePassword();
        $user->password = $plainPassword;
        $user->save();

        // Barcha tokenlarni o'chirish (majburiy logout)
        $user->tokens()->delete();

        // Logga yozish
        PasswordResetLog::create([
            'officer_id' => $officer->id,
            'username' => $user->username,
            'ip_address' => $request->ip(),
        ]);

        return response()->json([
            'message' => 'Parol muvaffaqiyatli tiklandi.',
            'credentials' => [
                'username' => $user->username,
                'password' => $plainPassword,
            ],
        ]);
    }

    public function logs(Request $request): JsonResponse
    {
        $logs = PasswordResetLog::with('officer:id,full_name')
            ->latest('created_at')
            ->paginate(20);

        return response()->json($logs);
    }
}
