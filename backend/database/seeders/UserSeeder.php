<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Rahbariyat user
        User::create([
            'name' => 'Admin Rahbar',
            'username' => 'admin',
            'email' => 'admin@yoshlar.uz',
            'phone' => '+998901234567',
            'role' => 'rahbariyat',
            'password' => 'password',
        ]);

        // Masul users
        User::create([
            'name' => 'Abdullayev Jasur',
            'username' => 'jasur.abdullayev',
            'email' => 'jasur@yoshlar.uz',
            'phone' => '+998901111111',
            'role' => 'masul',
            'password' => 'password',
        ]);

        User::create([
            'name' => 'Karimov Bobur',
            'username' => 'bobur.karimov',
            'email' => 'bobur@yoshlar.uz',
            'phone' => '+998902222222',
            'role' => 'masul',
            'password' => 'password',
        ]);

        User::create([
            'name' => 'Toshmatov Sardor',
            'username' => 'sardor.toshmatov',
            'email' => 'sardor@yoshlar.uz',
            'phone' => '+998903333333',
            'role' => 'masul',
            'password' => 'password',
        ]);
    }
}
