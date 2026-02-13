<?php

namespace Database\Seeders;

use App\Models\Activity;
use App\Models\Youth;
use Illuminate\Database\Seeder;

class ActivitySeeder extends Seeder
{
    public function run(): void
    {
        $activities = [
            ['title' => 'Suhbat', 'description' => "Individual suhbat o'tkazildi", 'result' => "Ijobiy, yoshda o'zgarish kuzatilmoqda", 'status' => 'bajarilgan'],
            ['title' => 'Amaliy Ish', 'description' => "Sport to'garagiga yozdirish", 'result' => 'Rejalashtirilgan', 'status' => 'rejalashtirilgan'],
            ['title' => 'Uchrashuv', 'description' => "Ota-onalar bilan uchrashuv o'tkazildi", 'result' => "Oila bilan munosabatlar yaxshilandi", 'status' => 'bajarilgan'],
            ['title' => 'Suhbat', 'description' => "Psixolog bilan suhbat tashkil etildi", 'result' => "Davom ettiriladi", 'status' => 'bajarilgan'],
            ['title' => 'Amaliy Ish', 'description' => "Kasb-hunar kursiga yo'naltirish", 'result' => null, 'status' => 'rejalashtirilgan'],
            ['title' => 'Uchrashuv', 'description' => "Mahalla rahbari bilan uchrashuv", 'result' => "Yoshga ish topishda yordam berildi", 'status' => 'bajarilgan'],
        ];

        $youths = Youth::all();
        $date = now()->subMonths(3);

        foreach ($youths as $youth) {
            $count = rand(1, 3);
            for ($i = 0; $i < $count; $i++) {
                $template = $activities[array_rand($activities)];
                $template['date'] = $date->copy()->addDays(rand(0, 90))->format('Y-m-d');
                $template['officer_id'] = $youth->officers()->first()?->id;

                $youth->activities()->create($template);
            }
        }
    }
}
