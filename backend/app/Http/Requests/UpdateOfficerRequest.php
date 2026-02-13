<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateOfficerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isRahbariyat();
    }

    public function rules(): array
    {
        return [
            'fullName' => ['sometimes', 'string', 'max:255'],
            'position' => ['sometimes', 'string', 'max:255'],
            'region_id' => ['nullable', 'exists:regions,id'],
            'region' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'regex:/^\+?998\d{9}$/', 'max:13'],
            'photo' => ['nullable', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
        ];
    }
}
