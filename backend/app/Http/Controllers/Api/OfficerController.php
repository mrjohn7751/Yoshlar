<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AttachYouthsRequest;
use Illuminate\Http\Request as HttpRequest;
use App\Http\Requests\StoreOfficerRequest;
use App\Http\Requests\UpdateOfficerRequest;
use App\Services\CredentialGenerator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Http\Resources\OfficerResource;
use App\Http\Resources\YouthResource;
use App\Models\Officer;
use App\Models\Region;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class OfficerController extends Controller
{
    public function index(HttpRequest $request): JsonResponse
    {
        $query = Officer::with(['region', 'user'])
            ->withCount('youths')
            ->latest();

        if ($request->boolean('all')) {
            return response()->json([
                'data' => OfficerResource::collection($query->get()),
            ]);
        }

        $officers = $query->paginate(20);

        return response()->json(OfficerResource::collection($officers)->response()->getData(true));
    }

    public function store(StoreOfficerRequest $request): JsonResponse
    {
        $debug = [];
        $debug['has_file_photo'] = $request->hasFile('photo');
        $debug['all_files'] = array_keys($request->allFiles());
        $debug['validated_keys'] = array_keys($request->validated());

        $data = $request->validated();

        // fullName -> full_name
        if (isset($data['fullName'])) {
            $data['full_name'] = $data['fullName'];
            unset($data['fullName']);
        }

        // region nomi bo'yicha region_id topish
        if (isset($data['region']) && !isset($data['region_id'])) {
            $region = Region::where('name', 'like', '%' . str_replace(['%', '_'], ['\\%', '\\_'], $data['region']) . '%')->first();
            if ($region) {
                $data['region_id'] = $region->id;
            }
            unset($data['region']);
        }

        // Fayl bo'lmasa photo kalitini o'chirib tashlash
        if ($request->hasFile('photo')) {
            Storage::disk('public')->makeDirectory('officers');
            $storedPath = $request->file('photo')->store('officers', 'public');
            if ($storedPath === false) {
                $fileName = uniqid() . '.jpg';
                $request->file('photo')->move(Storage::disk('public')->path('officers'), $fileName);
                $storedPath = 'officers/' . $fileName;
            }
            $debug['stored_path'] = $storedPath;
            $data['photo'] = $storedPath;
        } else {
            unset($data['photo']);
            $debug['photo_skipped'] = 'no file received';
        }

        $debug['data_has_photo'] = array_key_exists('photo', $data);
        $debug['data_photo_value'] = $data['photo'] ?? 'NOT_SET';

        // Auto-generate credentials for the officer
        $credentialGenerator = new CredentialGenerator();
        $username = $credentialGenerator->fromFullName($data['full_name']);
        $plainPassword = $credentialGenerator->generatePassword();

        $officer = DB::transaction(function () use ($data, $username, $plainPassword) {
            $user = User::create([
                'name' => $data['full_name'],
                'username' => $username,
                'email' => $username . '@yoshlar.uz',
                'phone' => $data['phone'] ?? null,
                'password' => $plainPassword,
            ]);
            $user->role = 'masul';
            $user->save();

            $officer = Officer::create($data);
            $officer->user_id = $user->id;
            $officer->save();
            return $officer;
        });

        $officer->refresh();
        $debug['officer_photo_in_db'] = $officer->photo;

        $officer->load(['region', 'user']);

        return response()->json([
            'message' => 'Mas\'ul xodim muvaffaqiyatli qo\'shildi.',
            'data' => new OfficerResource($officer),
            'credentials' => [
                'username' => $username,
                'password' => $plainPassword,
            ],
            '_debug' => $debug,
        ], 201);
    }

    public function update(UpdateOfficerRequest $request, Officer $officer): JsonResponse
    {
        $data = $request->validated();

        if (isset($data['fullName'])) {
            $data['full_name'] = $data['fullName'];
            unset($data['fullName']);
        }

        if (isset($data['region']) && !isset($data['region_id'])) {
            $region = Region::where('name', 'like', '%' . str_replace(['%', '_'], ['\\%', '\\_'], $data['region']) . '%')->first();
            if ($region) {
                $data['region_id'] = $region->id;
            }
            unset($data['region']);
        }

        if ($request->hasFile('photo')) {
            if ($officer->photo) {
                Storage::disk('public')->delete($officer->photo);
            }
            Storage::disk('public')->makeDirectory('officers');
            $storedPath = $request->file('photo')->store('officers', 'public');
            if ($storedPath === false) {
                $fileName = uniqid() . '.jpg';
                $request->file('photo')->move(Storage::disk('public')->path('officers'), $fileName);
                $storedPath = 'officers/' . $fileName;
            }
            $data['photo'] = $storedPath;
        } else {
            unset($data['photo']);
        }

        $officer->update($data);
        $officer->load(['region', 'user']);
        $officer->loadCount('youths');

        return response()->json([
            'message' => 'Mas\'ul xodim muvaffaqiyatli yangilandi.',
            'data' => new OfficerResource($officer),
        ]);
    }

    public function destroy(Officer $officer): JsonResponse
    {
        if ($officer->photo) {
            Storage::disk('public')->delete($officer->photo);
        }

        // Delete associated user and revoke tokens
        if ($officer->user_id) {
            $user = User::find($officer->user_id);
            if ($user) {
                $user->tokens()->delete();
                $user->delete();
            }
        }

        $officer->delete();

        return response()->json([
            'message' => 'Mas\'ul xodim muvaffaqiyatli o\'chirildi.',
        ]);
    }

    public function show(Officer $officer): JsonResponse
    {
        $officer->load(['region', 'user']);
        $officer->loadCount('youths');

        return response()->json([
            'data' => new OfficerResource($officer),
        ]);
    }

    public function youths(HttpRequest $request, Officer $officer): JsonResponse
    {
        $query = $officer->youths()
            ->with(['region', 'categories'])
            ->withCount('activities');

        if ($request->boolean('all')) {
            return response()->json([
                'data' => YouthResource::collection($query->get()),
            ]);
        }

        $youths = $query->paginate(20);

        return response()->json(YouthResource::collection($youths)->response()->getData(true));
    }

    public function attachYouths(AttachYouthsRequest $request, Officer $officer): JsonResponse
    {
        $officer->youths()->syncWithoutDetaching($request->youth_ids);

        return response()->json([
            'message' => 'Yoshlar muvaffaqiyatli biriktirildi.',
        ]);
    }

    public function detachYouths(AttachYouthsRequest $request, Officer $officer): JsonResponse
    {
        $officer->youths()->detach($request->youth_ids);

        return response()->json([
            'message' => 'Yoshlar muvaffaqiyatli ajratildi.',
        ]);
    }

    public function generateCredentials(Officer $officer): JsonResponse
    {
        if ($officer->user_id) {
            return response()->json([
                'message' => 'Bu mas\'ulning allaqachon akkaunti mavjud.',
            ], 422);
        }

        $credentialGenerator = new CredentialGenerator();
        $username = $credentialGenerator->fromFullName($officer->full_name);
        $plainPassword = $credentialGenerator->generatePassword();

        $user = DB::transaction(function () use ($officer, $username, $plainPassword) {
            $user = User::create([
                'name' => $officer->full_name,
                'username' => $username,
                'email' => $username . '@yoshlar.uz',
                'phone' => $officer->phone,
                'password' => $plainPassword,
            ]);
            $user->role = 'masul';
            $user->save();

            $officer->user_id = $user->id;
            $officer->save();
            return $user;
        });

        return response()->json([
            'message' => 'Akkaunt muvaffaqiyatli yaratildi.',
            'credentials' => [
                'username' => $username,
                'password' => $plainPassword,
            ],
        ]);
    }

    public function resetPassword(Officer $officer): JsonResponse
    {
        if (!$officer->user_id) {
            return response()->json([
                'message' => 'Bu mas\'ulning foydalanuvchi akkaunti topilmadi.',
            ], 404);
        }

        $user = User::findOrFail($officer->user_id);
        $credentialGenerator = new CredentialGenerator();
        $plainPassword = $credentialGenerator->generatePassword();
        $user->password = $plainPassword;
        $user->save();

        // Barcha eski tokenlarni bekor qilish
        $user->tokens()->delete();

        return response()->json([
            'message' => 'Parol muvaffaqiyatli yangilandi.',
            'credentials' => [
                'username' => $user->username,
                'password' => $plainPassword,
            ],
        ]);
    }
}
