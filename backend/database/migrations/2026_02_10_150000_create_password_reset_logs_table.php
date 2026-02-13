<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('password_reset_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('officer_id')->constrained()->onDelete('cascade');
            $table->string('username');
            $table->string('ip_address', 45)->nullable();
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('password_reset_logs');
    }
};
