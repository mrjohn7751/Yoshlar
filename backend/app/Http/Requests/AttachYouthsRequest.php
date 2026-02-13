<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AttachYouthsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->isRahbariyat();
    }

    public function rules(): array
    {
        return [
            'youth_ids' => ['required', 'array', 'min:1'],
            'youth_ids.*' => ['exists:youths,id'],
        ];
    }
}
