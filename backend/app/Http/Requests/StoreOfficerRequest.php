<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOfficerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isRahbariyat();
    }

    public function rules(): array
    {
        return [
            'fullName' => ['required', 'string', 'max:255'],
            'position' => ['required', 'string', 'max:255'],
            'region_id' => ['nullable', 'exists:regions,id'],
            'region' => ['nullable', 'string'], // hudud nomi
            'phone' => ['nullable', 'string', 'regex:/^\+?998\d{9}$/', 'max:13'],
            'photo' => ['nullable', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
        ];
    }
}
