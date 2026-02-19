<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreActivityRequest;
use App\Http\Resources\ActivityResource;
use App\Models\Activity;
use App\Models\Youth;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Activity::with(['officer', 'youth', 'images'])
            ->withCount('comments');

        if ($request->filled('officer_id')) {
            $query->where('officer_id', $request->officer_id);
        }

        $activities = $query->latest('date')->paginate(20);

        return response()->json(ActivityResource::collection($activities)->response()->getData(true));
    }

    public function indexForYouth(Request $request, Youth $youth): JsonResponse
    {
        $query = $youth->activities()
            ->with(['officer', 'images'])
            ->withCount('comments')
            ->latest('date')
            ->latest('id');

        if ($request->boolean('all')) {
            return response()->json([
                'data' => ActivityResource::collection($query->get()),
            ]);
        }

        $activities = $query->paginate(20);

        return response()->json(ActivityResource::collection($activities)->response()->getData(true));
    }

    public function store(Youth $youth, StoreActivityRequest $request): JsonResponse
    {
        // Masul faqat o'ziga biriktirilgan yoshga activity yoza oladi
        $officer = $request->user()->officer;
        if (!$officer || !$officer->youths()->where('youths.id', $youth->id)->exists()) {
            return response()->json(['message' => 'Bu yoshga faoliyat qo\'shish huquqingiz yo\'q.'], 403);
        }

        $data = $request->validated();

        $activity = $youth->activities()->create($data);
        $activity->officer_id = $officer->id;
        $activity->save();
        $activity->load(['officer', 'images']);

        return response()->json([
            'message' => 'Faoliyat muvaffaqiyatli qo\'shildi.',
            'data' => new ActivityResource($activity),
        ], 201);
    }

    public function show(Activity $activity): JsonResponse
    {
        $activity->load(['officer', 'images', 'youth']);
        $activity->loadCount('comments');

        return response()->json([
            'data' => new ActivityResource($activity),
        ]);
    }

    public function uploadImages(Activity $activity): JsonResponse
    {
        // Masul faqat o'z activity-siga rasm yuklashi mumkin
        $officer = request()->user()->officer;
        if (!$officer || $activity->officer_id !== $officer->id) {
            return response()->json(['message' => 'Bu faoliyatga rasm yuklash huquqingiz yo\'q.'], 403);
        }

        request()->validate([
            'images' => ['required', 'array', 'min:3', 'max:10'],
            'images.*' => ['image', 'mimes:jpeg,png,jpg', 'max:5120'],
        ]);

        Storage::disk('public')->makeDirectory('activities');
        $uploaded = [];
        foreach (request()->file('images') as $image) {
            $path = $image->store('activities', 'public');
            if ($path === false) {
                $fileName = uniqid() . '.jpg';
                $image->move(Storage::disk('public')->path('activities'), $fileName);
                $path = 'activities/' . $fileName;
            }
            $uploaded[] = $activity->images()->create(['path' => $path]);
        }

        return response()->json([
            'message' => count($uploaded) . ' ta rasm yuklandi.',
            'data' => $uploaded,
        ], 201);
    }
}
