<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('youths', function (Blueprint $table) {
            $table->id();
            $table->string('full_name');
            $table->string('photo')->nullable();
            $table->date('birth_date');
            $table->string('gender'); // Erkak, Ayol
            $table->text('address')->nullable();
            $table->foreignId('region_id')->constrained()->cascadeOnDelete();
            $table->string('education_status')->nullable(); // O'qimoqda, Bitirgan
            $table->string('employment_status')->nullable(); // Ishsiz, Ishlamoqda
            $table->string('risk_level')->default('O\'rta xavf'); // Past xavf, O'rta xavf, Yuqori xavf
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('youths');
    }
};
