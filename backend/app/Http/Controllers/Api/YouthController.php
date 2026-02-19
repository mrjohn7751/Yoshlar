<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreYouthRequest;
use App\Http\Requests\UpdateYouthRequest;
use App\Http\Resources\YouthResource;
use App\Models\Category;
use App\Models\Region;
use App\Models\Youth;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class YouthController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Youth::with(['region', 'categories', 'officers'])
            ->withCount('activities');

        if ($request->filled('region')) {
            $query->where('region_id', $request->region);
        }

        if ($request->filled('gender')) {
            $query->where('gender', $request->gender);
        }

        if ($request->filled('category')) {
            $query->whereHas('categories', function ($q) use ($request) {
                $q->where('categories.id', $request->category);
            });
        }

        if ($request->filled('officer_id')) {
            $query->whereHas('officers', function ($q) use ($request) {
                $q->where('officers.id', $request->officer_id);
            });
        }

        if ($request->filled('search')) {
            $search = str_replace(['%', '_'], ['\\%', '\\_'], $request->search);
            $query->where('full_name', 'like', '%' . $search . '%');
        }

        if ($request->boolean('all')) {
            return response()->json([
                'data' => YouthResource::collection($query->latest()->get()),
            ]);
        }

        $youths = $query->latest()->paginate(20);

        return response()->json(YouthResource::collection($youths)->response()->getData(true));
    }

    public function store(StoreYouthRequest $request): JsonResponse
    {
        $debug = [];

        try {
            $debug['step'] = '1_validated';
            $validated = $request->validated();
            $debug['validated_keys'] = array_keys($validated);
            $debug['has_file_image'] = $request->hasFile('image');
            $debug['all_files'] = array_keys($request->allFiles());

            $data = $this->mapFrontendFields($validated);
            $debug['step'] = '2_mapped';
            $debug['mapped_keys'] = array_keys($data);

            if ($request->hasFile('image')) {
                // Papka mavjudligini tekshirish va yaratish
                Storage::disk('public')->makeDirectory('youths');

                $storedPath = $request->file('image')->store('youths', 'public');
                $debug['step'] = '3_stored';
                $debug['stored_path'] = $storedPath;
                $debug['stored_type'] = gettype($storedPath);

                if ($storedPath === false) {
                    // Storage xatosi - batafsil ma'lumot
                    $debug['storage_error'] = true;
                    $debug['storage_path'] = Storage::disk('public')->path('youths');
                    $debug['storage_writable'] = is_writable(Storage::disk('public')->path('youths'));
                    $debug['storage_exists'] = Storage::disk('public')->exists('youths');
                    $debug['file_valid'] = $request->file('image')->isValid();
                    $debug['file_size'] = $request->file('image')->getSize();
                    $debug['file_error'] = $request->file('image')->getError();

                    // Muqobil usul: move orqali saqlash
                    $fileName = uniqid() . '.jpg';
                    $destinationPath = Storage::disk('public')->path('youths');
                    $request->file('image')->move($destinationPath, $fileName);
                    $storedPath = 'youths/' . $fileName;
                    $debug['fallback_path'] = $storedPath;
                }

                $data['photo'] = $storedPath;
            } else {
                $debug['step'] = '3_no_file';
            }

            $categoryIds = $this->resolveCategoryIds($request);
            unset($data['tags'], $data['category_ids'], $data['image']);

            $debug['step'] = '4_before_create';
            $debug['data_has_photo'] = array_key_exists('photo', $data);
            $debug['data_photo_value'] = $data['photo'] ?? 'NOT_SET';

            $youth = Youth::create($data);

            $debug['step'] = '5_created';
            $debug['youth_id'] = $youth->id;
            $debug['youth_photo_after_create'] = $youth->photo;

            // Bazadan qayta o'qish
            $youth->refresh();
            $debug['youth_photo_after_refresh'] = $youth->photo;

            if (!empty($categoryIds)) {
                $youth->categories()->sync($categoryIds);
            }

            $youth->load(['region', 'categories']);

            return response()->json([
                'message' => 'Yosh muvaffaqiyatli qo\'shildi.',
                'data' => new YouthResource($youth),
                '_debug' => $debug,
            ], 201);
        } catch (\Exception $e) {
            $debug['error'] = $e->getMessage();
            $debug['error_file'] = $e->getFile() . ':' . $e->getLine();
            return response()->json([
                'message' => 'Xatolik: ' . $e->getMessage(),
                '_debug' => $debug,
            ], 500);
        }
    }

    public function show(Youth $youth): JsonResponse
    {
        $youth->load(['region', 'categories', 'officers.region']);
        $youth->loadCount('activities');

        return response()->json([
            'data' => new YouthResource($youth),
        ]);
    }

    public function update(UpdateYouthRequest $request, Youth $youth): JsonResponse
    {
        try {
            $data = $this->mapFrontendFields($request->validated());

            if ($request->hasFile('image')) {
                if ($youth->photo) {
                    Storage::disk('public')->delete($youth->photo);
                }
                Storage::disk('public')->makeDirectory('youths');
                $storedPath = $request->file('image')->store('youths', 'public');
                if ($storedPath === false) {
                    $fileName = uniqid() . '.jpg';
                    $request->file('image')->move(Storage::disk('public')->path('youths'), $fileName);
                    $storedPath = 'youths/' . $fileName;
                }
                $data['photo'] = $storedPath;
            }

            $categoryIds = $this->resolveCategoryIds($request);
            unset($data['tags'], $data['category_ids'], $data['image']);

            $youth->update($data);

            if ($categoryIds !== null) {
                $youth->categories()->sync($categoryIds);
            }

            $youth->load(['region', 'categories']);

            return response()->json([
                'message' => 'Yosh muvaffaqiyatli yangilandi.',
                'data' => new YouthResource($youth),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Xatolik: ' . $e->getMessage(),
                '_debug_error' => $e->getMessage(),
                '_debug_file' => $e->getFile() . ':' . $e->getLine(),
            ], 500);
        }
    }

    public function updatePhoto(Request $request, Youth $youth): JsonResponse
    {
        // Masul faqat o'ziga biriktirilgan yoshning rasmini o'zgartira oladi
        $officer = $request->user()->officer;
        if (!$officer || !$officer->youths()->where('youths.id', $youth->id)->exists()) {
            return response()->json(['message' => 'Bu yoshni tahrirlash huquqingiz yo\'q.'], 403);
        }

        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($youth->photo) {
            Storage::disk('public')->delete($youth->photo);
        }

        Storage::disk('public')->makeDirectory('youths');
        $storedPath = $request->file('image')->store('youths', 'public');
        if ($storedPath === false) {
            $fileName = uniqid() . '.jpg';
            $request->file('image')->move(Storage::disk('public')->path('youths'), $fileName);
            $storedPath = 'youths/' . $fileName;
        }
        $youth->photo = $storedPath;
        $youth->save();

        $youth->load(['region', 'categories', 'officers']);

        return response()->json([
            'message' => 'Rasm muvaffaqiyatli yangilandi.',
            'data' => new YouthResource($youth),
        ]);
    }

    public function destroy(Youth $youth): JsonResponse
    {
        if ($youth->photo) {
            Storage::disk('public')->delete($youth->photo);
        }

        $youth->delete();

        return response()->json([
            'message' => 'Yosh muvaffaqiyatli o\'chirildi.',
        ]);
    }

    public function import(Request $request): JsonResponse
    {
        $request->validate([
            'youths' => 'required|array|min:1|max:500',
        ]);

        $rows = $request->input('youths');
        $success = 0;
        $failed = 0;
        $errors = [];

        DB::beginTransaction();

        try {
            foreach ($rows as $index => $row) {
                $rowNum = $index + 1;

                $validator = Validator::make($row, [
                    'name' => 'required|string|max:255',
                    'phone' => 'nullable|string|max:20',
                    'gender' => 'required|in:Erkak,Ayol',
                    'birthDate' => 'required|date',
                    'region' => 'nullable|string',
                    'location' => 'nullable|string',
                    'status' => 'nullable|string|max:255',
                    'activity' => 'nullable|string|max:255',
                    'riskLevel' => 'nullable|string|max:255',
                    'tags' => 'nullable|array',
                    'tags.*' => 'string',
                ]);

                if ($validator->fails()) {
                    $failed++;
                    $errors[] = [
                        'row' => $rowNum,
                        'name' => $row['name'] ?? '—',
                        'message' => $validator->errors()->first(),
                    ];
                    continue;
                }

                $data = $this->mapFrontendFields($validator->validated());

                // Resolve category tags
                $categoryIds = [];
                if (!empty($row['tags'])) {
                    $categoryIds = Category::whereIn('name', $row['tags'])->pluck('id')->toArray();
                }
                unset($data['tags']);

                $youth = Youth::create($data);

                if (!empty($categoryIds)) {
                    $youth->categories()->sync($categoryIds);
                }

                $success++;
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Import xatolik bilan to\'xtatildi.',
            ], 500);
        }

        return response()->json([
            'message' => "Import yakunlandi: $success ta muvaffaqiyatli, $failed ta xatolik.",
            'results' => [
                'success' => $success,
                'failed' => $failed,
                'errors' => $errors,
            ],
        ]);
    }

    private function mapFrontendFields(array $data): array
    {
        $mapped = [];

        // Frontend camelCase -> DB snake_case
        $fieldMap = [
            'name' => 'full_name',
            'birthDate' => 'birth_date',
            'location' => 'address',
            'status' => 'education_status',
            'activity' => 'employment_status',
            'riskLevel' => 'risk_level',
        ];

        foreach ($data as $key => $value) {
            $dbKey = $fieldMap[$key] ?? $key;
            $mapped[$dbKey] = $value;
        }

        // Region nomi bo'yicha region_id aniqlash
        if (isset($mapped['region']) && !isset($mapped['region_id'])) {
            $region = Region::where('name', 'like', '%' . str_replace(['%', '_'], ['\\%', '\\_'], $mapped['region']) . '%')->first();
            if ($region) {
                $mapped['region_id'] = $region->id;
            }
            unset($mapped['region']);
        }

        return $mapped;
    }

    private function resolveCategoryIds(Request $request): ?array
    {
        // category_ids to'g'ridan-to'g'ri kelsa
        if ($request->filled('category_ids')) {
            return $request->category_ids;
        }

        // tags (category nomlari) kelsa - id larga o'giramiz
        if ($request->filled('tags')) {
            return Category::whereIn('name', $request->tags)->pluck('id')->toArray();
        }

        return null;
    }
}
