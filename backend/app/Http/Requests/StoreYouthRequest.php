<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreYouthRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isRahbariyat();
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'regex:/^\+?998\d{9}$/', 'max:13'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
            'birthDate' => ['required', 'date'],
            'gender' => ['required', 'in:Erkak,Ayol'],
            'location' => ['nullable', 'string', 'max:5000'],
            'region_id' => ['nullable', 'exists:regions,id'],
            'region' => ['nullable', 'string'], // tuman nomi bo'yicha qidirish
            'status' => ['nullable', 'string', 'max:255'], // education
            'activity' => ['nullable', 'string', 'max:255'], // employment
            'riskLevel' => ['nullable', 'string', 'in:past,orta,yuqori'],
            'description' => ['nullable', 'string', 'max:5000'],
            'tags' => ['nullable', 'array'], // category nomlari
            'tags.*' => ['string', 'max:255'],
            'category_ids' => ['nullable', 'array'], // category id lari
            'category_ids.*' => ['exists:categories,id'],
        ];
    }
}
