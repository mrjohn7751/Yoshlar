<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('youth_officer', function (Blueprint $table) {
            $table->id();
            $table->foreignId('youth_id')->constrained()->cascadeOnDelete();
            $table->foreignId('officer_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['youth_id', 'officer_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('youth_officer');
    }
};
