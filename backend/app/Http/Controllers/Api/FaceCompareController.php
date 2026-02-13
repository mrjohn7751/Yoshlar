<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Officer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class FaceCompareController extends Controller
{
    public function compare(Request $request): JsonResponse
    {
        $request->validate([
            'officer_id' => ['required', 'exists:officers,id'],
            'selfie' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:5120'],
        ]);

        $officer = Officer::findOrFail($request->officer_id);

        // Masul faqat o'z officer profilini solishtira oladi
        $user = $request->user();
        if ($user->officer && $user->officer->id !== $officer->id) {
            return response()->json([
                'match' => false,
                'message' => "Faqat o'z profilingiz bilan solishtirish mumkin.",
            ], 403);
        }

        if (empty($officer->photo)) {
            return response()->json([
                'match' => false,
                'message' => "Mas'ul rasmi yuklanmagan",
            ], 400);
        }

        $serviceUrl = config('face_service.url');
        $serviceKey = config('face_service.key');
        $timeout = config('face_service.timeout', 30);

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
                    'match' => false,
                    'message' => 'Yuz servisi autentifikatsiya xatosi.',
                ], 500);
            }

            if ($response->status() === 403) {
                $data = $response->json();
                return response()->json([
                    'match' => false,
                    'is_real' => $data['is_real'] ?? false,
                    'message' => $data['message'] ?? 'Soxta rasm aniqlandi.',
                ], 403);
            }

            if ($response->successful()) {
                $data = $response->json();
                return response()->json([
                    'match' => $data['match'] ?? false,
                    'similarity' => $data['similarity'] ?? null,
                    'is_real' => $data['is_real'] ?? null,
                    'message' => $data['message'] ?? null,
                ]);
            }

            $data = $response->json();
            return response()->json([
                'match' => false,
                'message' => $data['message'] ?? 'Yuz solishtirish xatosi',
            ], $response->status());

        } catch (\Exception $e) {
            return response()->json([
                'match' => false,
                'message' => 'Yuz solishtirish servisi vaqtincha ishlamayapti.',
            ], 503);
        }
    }
}
