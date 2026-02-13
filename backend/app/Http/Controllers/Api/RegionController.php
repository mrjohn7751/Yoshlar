<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RegionResource;
use App\Models\Region;
use Illuminate\Http\JsonResponse;

class RegionController extends Controller
{
    public function index(): JsonResponse
    {
        $regions = Region::withCount('youths')->get();

        return response()->json([
            'data' => RegionResource::collection($regions),
        ]);
    }
}
