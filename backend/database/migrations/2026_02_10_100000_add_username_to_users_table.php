<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add nullable username column first
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable()->after('name');
        });

        // Backfill existing users: derive username from email prefix
        DB::table('users')->whereNull('username')->get()->each(function ($user) {
            $username = explode('@', $user->email)[0];
            // Ensure uniqueness
            $base = $username;
            $counter = 1;
            while (DB::table('users')->where('username', $username)->where('id', '!=', $user->id)->exists()) {
                $username = $base . $counter;
                $counter++;
            }
            DB::table('users')->where('id', $user->id)->update(['username' => $username]);
        });

        // Now add unique index and make non-nullable
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable(false)->change();
            $table->unique('username');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['username']);
            $table->dropColumn('username');
        });
    }
};
