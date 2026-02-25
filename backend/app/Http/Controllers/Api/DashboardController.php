<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\RegionResource;
use App\Models\Category;
use App\Models\Region;
use App\Models\Youth;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function stats(): JsonResponse
    {
        $stats = Youth::query()
            ->selectRaw("COUNT(*) as total")
            ->selectRaw("SUM(CASE WHEN gender = 'Erkak' THEN 1 ELSE 0 END) as boys")
            ->selectRaw("SUM(CASE WHEN gender = 'Ayol' THEN 1 ELSE 0 END) as girls")
            ->first();

        return response()->json([
            'jamiYoshlar' => (int) $stats->total,
            'ogilBolalar' => (int) $stats->boys,
            'qizBolalar' => (int) $stats->girls,
        ]);
    }

    public function regions(Request $request): JsonResponse
    {
        $query = Region::withCount('youths')->orderBy('name');

        if ($request->has('per_page')) {
            $perPage = min((int) $request->get('per_page', 15), 50);
            $paginated = $query->paginate($perPage);

            return response()->json([
                'data' => RegionResource::collection($paginated),
                'meta' => [
                    'current_page' => $paginated->currentPage(),
                    'last_page' => $paginated->lastPage(),
                    'per_page' => $paginated->perPage(),
                    'total' => $paginated->total(),
                ],
            ]);
        }

        return response()->json([
            'data' => RegionResource::collection($query->get()),
        ]);
    }

    public function categories(Request $request): JsonResponse
    {
        $query = Category::withCount('youths')->orderBy('name');

        if ($request->has('per_page')) {
            $perPage = min((int) $request->get('per_page', 15), 50);
            $paginated = $query->paginate($perPage);

            return response()->json([
                'data' => CategoryResource::collection($paginated),
                'meta' => [
                    'current_page' => $paginated->currentPage(),
                    'last_page' => $paginated->lastPage(),
                    'per_page' => $paginated->perPage(),
                    'total' => $paginated->total(),
                ],
            ]);
        }

        return response()->json([
            'data' => CategoryResource::collection($query->get()),
        ]);
    }
}
