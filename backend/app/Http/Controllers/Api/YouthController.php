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
        $data = $this->mapFrontendFields($request->validated());

        if ($request->hasFile('image')) {
            $data['photo'] = $request->file('image')->store('youths', 'public');
        }

        $categoryIds = $this->resolveCategoryIds($request);
        unset($data['tags'], $data['category_ids'], $data['image']);

        $youth = Youth::create($data);

        if (!empty($categoryIds)) {
            $youth->categories()->sync($categoryIds);
        }

        $youth->load(['region', 'categories']);

        return response()->json([
            'message' => 'Yosh muvaffaqiyatli qo\'shildi.',
            'data' => new YouthResource($youth),
        ], 201);
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
        $data = $this->mapFrontendFields($request->validated());

        if ($request->hasFile('image')) {
            if ($youth->photo) {
                Storage::disk('public')->delete($youth->photo);
            }
            $data['photo'] = $request->file('image')->store('youths', 'public');
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

        $youth->photo = $request->file('image')->store('youths', 'public');
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
