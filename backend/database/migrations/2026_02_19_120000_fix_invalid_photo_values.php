<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Noto'g'ri photo qiymatlarni (0, 1, empty string) NULL ga o'zgartirish.
     */
    public function up(): void
    {
        // Youths jadvalidagi noto'g'ri photo qiymatlarni tozalash
        DB::table('youths')
            ->where('photo', '0')
            ->orWhere('photo', '1')
            ->orWhere('photo', '')
            ->update(['photo' => null]);

        // Officers jadvalidagi noto'g'ri photo qiymatlarni tozalash
        DB::table('officers')
            ->where('photo', '0')
            ->orWhere('photo', '1')
            ->orWhere('photo', '')
            ->update(['photo' => null]);

        // Users jadvalidagi noto'g'ri photo qiymatlarni tozalash
        DB::table('users')
            ->where('photo', '0')
            ->orWhere('photo', '1')
            ->orWhere('photo', '')
            ->update(['photo' => null]);
    }

    public function down(): void
    {
        // Qaytarib bo'lmaydi
    }
};
