<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\RegionResource;
use App\Models\Category;
use App\Models\Region;
use App\Models\Youth;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function stats(): JsonResponse
    {
        $total = Youth::count();
        $boys = Youth::where('gender', 'Erkak')->count();
        $girls = Youth::where('gender', 'Ayol')->count();

        return response()->json([
            'jamiYoshlar' => $total,
            'ogilBolalar' => $boys,
            'qizBolalar' => $girls,
        ]);
    }

    public function regions(): JsonResponse
    {
        $regions = Region::withCount('youths')->get();

        return response()->json([
            'data' => RegionResource::collection($regions),
        ]);
    }

    public function categories(): JsonResponse
    {
        $categories = Category::withCount('youths')->get();

        return response()->json([
            'data' => CategoryResource::collection($categories),
        ]);
    }
}
