<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'username' => ['sometimes', 'string', 'min:3', 'max:50', 'regex:/^[a-z0-9.]+$/', 'unique:users,username,' . $this->user()->id],
            'current_password' => ['required_with:new_password', 'string'],
            'new_password' => ['sometimes', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'username.regex' => 'Foydalanuvchi nomi faqat kichik harflar, raqamlar va nuqtadan iborat bo\'lishi kerak.',
            'username.unique' => 'Bu foydalanuvchi nomi allaqachon band.',
            'current_password.required_with' => 'Yangi parol o\'rnatish uchun joriy parolni kiriting.',
            'new_password.min' => 'Yangi parol kamida 8 ta belgidan iborat bo\'lishi kerak.',
            'new_password.confirmed' => 'Parollar mos kelmadi.',
        ];
    }
}
