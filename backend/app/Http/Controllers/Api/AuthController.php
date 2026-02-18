<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = [
            'username' => $request->login,
            'password' => $request->password,
        ];

        if (!Auth::attempt($credentials)) {
            return response()->json([
                'message' => 'Login yoki parol noto\'g\'ri.',
            ], 401);
        }

        $user = Auth::user();
        $user->load('officer');
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function logout(): JsonResponse
    {
        auth()->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Muvaffaqiyatli chiqildi.',
        ]);
    }

    public function me(): JsonResponse
    {
        $user = auth()->user();
        $user->load('officer');

        return response()->json([
            'user' => new UserResource($user),
        ]);
    }

    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = auth()->user();

        if ($request->has('username')) {
            $user->username = $request->username;
        }

        if ($request->has('new_password')) {
            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'message' => 'Joriy parol noto\'g\'ri.',
                ], 422);
            }
            $user->password = $request->new_password;

            // Eski tokenlarni bekor qilish (joriy tokendan tashqari)
            $currentTokenId = $user->currentAccessToken()->id;
            $user->tokens()->where('id', '!=', $currentTokenId)->delete();
        }

        $user->save();
        $user->load('officer');

        return response()->json([
            'message' => 'Profil muvaffaqiyatli yangilandi.',
            'user' => new UserResource($user),
        ]);
    }

    public function updatePhoto(Request $request): JsonResponse
    {
        $request->validate([
            'photo' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
        ]);

        $user = auth()->user();

        // Eski rasmni o'chirish
        if ($user->photo) {
            Storage::disk('public')->delete($user->photo);
        }

        $path = $request->file('photo')->store('users', 'public');
        $user->photo = $path;
        $user->save();
        $user->load('officer');

        return response()->json([
            'message' => 'Rasm muvaffaqiyatli yangilandi.',
            'user' => new UserResource($user),
        ]);
    }
}
