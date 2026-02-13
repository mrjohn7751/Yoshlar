<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        // Frontend tartibida (main.dart dagi categories ro'yxatiga mos)
        $categories = [
            ['name' => 'Probatsiya nazoratidagilar', 'description' => 'Probatsiya nazorati ostida turgan yoshlar'],
            ['name' => 'Ilgari sudlanganlar', 'description' => 'Avval sudlanganlik tarixi bor yoshlar'],
            ['name' => "Yod g'oyalar ta'siriga tushganlar", 'description' => "Ekstremistik g'oyalar ta'siriga tushgan yoshlar"],
            ['name' => 'Jinoyat sodir etgan voyaga yetmaganlar', 'description' => 'Jinoyat sodir etgan voyaga yetmagan yoshlar'],
            ['name' => 'Giyohvandlar va spirtli ichimliklar ruju quyganlar', 'description' => 'Giyohvandlik yoki spirtli ichimliklar muammosi bor yoshlar'],
            ['name' => 'Mehribonlik uyidan chiqqanlar', 'description' => 'Mehribonlik uyidan chiqqan yoshlar'],
            ['name' => 'Agressiv xulq-atvorli yoshlar', 'description' => "Agressiv xulq-atvor ko'rsatgan yoshlar"],
            ['name' => "Ma'muriy huquqbuzarlik sodir etganlar", 'description' => "Ma'muriy huquqbuzarlik sodir etgan yoshlar"],
        ];

        foreach ($categories as $cat) {
            Category::create($cat);
        }
    }
}
