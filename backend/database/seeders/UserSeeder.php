<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin Rahbar',
            'username' => 'admin',
            'email' => 'admin@yoshlar.uz',
            'phone' => '+998901234567',
            'role' => 'rahbariyat',
            'password' => 'password',
        ]);
    }
}
