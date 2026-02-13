<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('youth_id')->constrained()->cascadeOnDelete();
            $table->foreignId('officer_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->text('result')->nullable();
            $table->date('date');
            $table->enum('status', ['bajarilgan', 'rejalashtirilgan'])->default('rejalashtirilgan');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activities');
    }
};
