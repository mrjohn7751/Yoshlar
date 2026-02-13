<?php

namespace Database\Seeders;

use App\Models\Officer;
use App\Models\User;
use Illuminate\Database\Seeder;

class OfficerSeeder extends Seeder
{
    public function run(): void
    {
        $masulUsers = User::where('role', 'masul')->get();

        $officers = [
            ['full_name' => 'Abdullayev Jasur Anvarovich', 'position' => 'Bosh mutaxassis', 'region_id' => 1, 'phone' => '+998901111111'],
            ['full_name' => 'Karimov Bobur Shavkatovich', 'position' => 'Katta inspektor', 'region_id' => 2, 'phone' => '+998902222222'],
            ['full_name' => 'Toshmatov Sardor Ilhomovich', 'position' => 'Inspektor', 'region_id' => 3, 'phone' => '+998903333333'],
            ['full_name' => 'Rahimov Alisher Kamoliddinovich', 'position' => 'Bosh mutaxassis', 'region_id' => 4, 'phone' => '+998904444444'],
            ['full_name' => 'Xolmatov Dilshod Baxtiyorovich', 'position' => 'Inspektor', 'region_id' => 5, 'phone' => '+998905555555'],
        ];

        foreach ($officers as $i => $data) {
            $data['user_id'] = $masulUsers[$i]->id ?? null;
            Officer::create($data);
        }
    }
}
