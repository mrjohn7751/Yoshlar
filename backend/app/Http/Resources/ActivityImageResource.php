<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;


class ActivityImageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'url' => $this->path && str_contains((string) $this->path, '/') ? $this->path : null,
            'created_at' => $this->created_at,
        ];
    }
}
