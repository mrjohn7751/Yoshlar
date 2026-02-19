<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;


class YouthResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->full_name,
            'phone' => $this->phone,
            'image' => $this->photo && str_contains((string) $this->photo, '/') ? $this->photo : null,
            '_debug_photo_raw' => $this->photo,
            'birthDate' => $this->birth_date?->format('Y-m-d'),
            'gender' => $this->gender,
            'location' => $this->address,
            'region' => new RegionResource($this->whenLoaded('region')),
            'region_id' => $this->region_id,
            'status' => $this->education_status,
            'activity' => $this->employment_status,
            'riskLevel' => $this->risk_level,
            'description' => $this->description,
            'tags' => $this->whenLoaded('categories', function () {
                return $this->categories->pluck('name')->toArray();
            }, []),
            'categories' => CategoryResource::collection($this->whenLoaded('categories')),
            'officers' => OfficerResource::collection($this->whenLoaded('officers')),
            'activitiesCount' => $this->whenCounted('activities'),
            'created_at' => $this->created_at,
        ];
    }
}
