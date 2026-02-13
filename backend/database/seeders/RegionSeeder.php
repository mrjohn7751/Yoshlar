<?php

namespace Database\Seeders;

use App\Models\Region;
use Illuminate\Database\Seeder;

class RegionSeeder extends Seeder
{
    public function run(): void
    {
        $regions = [
            'Jizzax shahar',
            'Arnasoy tumani',
            'Baxmal tumani',
            "G'allaorol tumani",
            "Do'stlik tumani",
            'Sharof Rashidov tumani',
            'Zomin tumani',
            'Zarbdor tumani',
            'Zafarobod tumani',
            "Mirzacho'l tumani",
            'Paxtakor tumani',
            'Forish tumani',
            'Yangiobod tumani',
        ];

        foreach ($regions as $name) {
            Region::create(['name' => $name]);
        }
    }
}
