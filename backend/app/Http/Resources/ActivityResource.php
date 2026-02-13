<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActivityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'youthId' => $this->youth_id,
            'youthName' => $this->whenLoaded('youth', fn() => $this->youth->full_name),
            'officer' => new OfficerResource($this->whenLoaded('officer')),
            'title' => $this->title,
            'description' => $this->description,
            'result' => $this->result,
            'date' => $this->date?->format('Y-m-d'),
            'status' => $this->status,
            'images' => ActivityImageResource::collection($this->whenLoaded('images')),
            'commentsCount' => $this->whenCounted('comments'),
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'created_at' => $this->created_at,
        ];
    }
}
