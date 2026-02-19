<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'username' => $this->username,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'officer_id' => $this->officer?->id,
            'photo' => $this->photo ? true : false,
            'photo_url' => $this->photo,
            'officer_photo' => $this->officer?->photo ? true : false,
            'officer_photo_url' => $this->officer?->photo,
            'created_at' => $this->created_at,
        ];
    }
}
