<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * "/" belgisi bo'lmagan barcha noto'g'ri photo qiymatlarni NULL ga o'zgartirish.
     * Haqiqiy fayl yo'li har doim "youths/xxx.jpg" yoki "officers/xxx.jpg" ko'rinishida bo'ladi.
     */
    public function up(): void
    {
        // Youths: photo ustunida "/" yo'q bo'lsa - noto'g'ri qiymat
        DB::table('youths')
            ->whereNotNull('photo')
            ->where('photo', 'NOT LIKE', '%/%')
            ->update(['photo' => null]);

        // Officers: photo ustunida "/" yo'q bo'lsa - noto'g'ri qiymat
        DB::table('officers')
            ->whereNotNull('photo')
            ->where('photo', 'NOT LIKE', '%/%')
            ->update(['photo' => null]);

        // Users: photo ustunida "/" yo'q bo'lsa - noto'g'ri qiymat
        DB::table('users')
            ->whereNotNull('photo')
            ->where('photo', 'NOT LIKE', '%/%')
            ->update(['photo' => null]);
    }

    public function down(): void
    {
        // Qaytarib bo'lmaydi
    }
};
