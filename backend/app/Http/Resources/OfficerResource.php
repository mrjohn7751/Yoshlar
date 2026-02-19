<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;


class OfficerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'userId' => $this->user_id,
            'username' => $this->whenLoaded('user', fn() => $this->user?->username),
            'fullName' => $this->full_name,
            'position' => $this->position,
            'region' => new RegionResource($this->whenLoaded('region')),
            'region_id' => $this->region_id,
            'phone' => $this->phone,
            'photo' => $this->photo && str_contains((string) $this->photo, '/') ? $this->photo : null,
            'youthsCount' => $this->whenCounted('youths'),
            'created_at' => $this->created_at,
        ];
    }
}
