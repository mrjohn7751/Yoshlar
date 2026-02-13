<?php

namespace Database\Seeders;

use App\Models\Youth;
use Illuminate\Database\Seeder;

class YouthSeeder extends Seeder
{
    public function run(): void
    {
        $youths = [
            ['full_name' => 'Islomov Azizbek Rustamovich', 'birth_date' => '2003-05-12', 'gender' => 'Erkak', 'address' => 'Jizzax shahar, Sharof Rashidov ko\'chasi 15', 'region_id' => 1, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Karimova Nilufar Baxtiyorovna', 'birth_date' => '2004-08-23', 'gender' => 'Ayol', 'address' => 'Arnasoy tumani, Mustaqillik ko\'chasi 8', 'region_id' => 2, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Tursunov Javohir Ilhomovich', 'birth_date' => '2002-01-15', 'gender' => 'Erkak', 'address' => 'Baxmal tumani, Navoiy ko\'chasi 22', 'region_id' => 3, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishlamoqda', 'risk_level' => 'Yuqori xavf'],
            ['full_name' => 'Rahmonov Sherzod Kamoliddinovich', 'birth_date' => '2001-11-30', 'gender' => 'Erkak', 'address' => "G'allaorol tumani, Amir Temur ko'chasi 5", 'region_id' => 4, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishsiz', 'risk_level' => 'Yuqori xavf'],
            ['full_name' => 'Abdullayeva Madina Faxriddinovna', 'birth_date' => '2005-03-07', 'gender' => 'Ayol', 'address' => "Do'stlik tumani, Yangi hayot ko'chasi 11", 'region_id' => 5, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Umarov Sardor Botirovich', 'birth_date' => '2003-07-19', 'gender' => 'Erkak', 'address' => 'Sharof Rashidov tumani, Bog\'ishamol 3', 'region_id' => 6, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Xolmatova Dilfuza Erkinovna', 'birth_date' => '2004-02-14', 'gender' => 'Ayol', 'address' => 'Zomin tumani, Bunyodkor ko\'chasi 7', 'region_id' => 7, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Normatov Bekzod Anvarovich', 'birth_date' => '2002-09-25', 'gender' => 'Erkak', 'address' => 'Zarbdor tumani, Istiqbol ko\'chasi 19', 'region_id' => 8, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishlamoqda', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Saidov Ulugbek Xasanovich', 'birth_date' => '2001-06-03', 'gender' => 'Erkak', 'address' => 'Zafarobod tumani, Tinchlik ko\'chasi 14', 'region_id' => 9, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishsiz', 'risk_level' => 'Yuqori xavf'],
            ['full_name' => 'Ergasheva Malika Toxirovna', 'birth_date' => '2005-12-08', 'gender' => 'Ayol', 'address' => "Mirzacho'l tumani, Oqtepa ko'chasi 6", 'region_id' => 10, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Qodirov Jasurbek Dilshodovich', 'birth_date' => '2003-04-17', 'gender' => 'Erkak', 'address' => 'Paxtakor tumani, Navro\'z ko\'chasi 21', 'region_id' => 11, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Yusupov Doniyor Shuhratovich', 'birth_date' => '2002-10-11', 'gender' => 'Erkak', 'address' => 'Forish tumani, Mustaqillik 30', 'region_id' => 12, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishlamoqda', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Aliyeva Sevinch Rustamovna', 'birth_date' => '2004-01-22', 'gender' => 'Ayol', 'address' => 'Yangiobod tumani, Guliston ko\'chasi 9', 'region_id' => 13, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Mirzayev Otabek Shavkatovich', 'birth_date' => '2001-08-05', 'gender' => 'Erkak', 'address' => 'Jizzax shahar, Navoiy ko\'chasi 45', 'region_id' => 1, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishsiz', 'risk_level' => 'Yuqori xavf'],
            ['full_name' => 'Tojiboyev Firdavs Bahodirovich', 'birth_date' => '2003-03-29', 'gender' => 'Erkak', 'address' => 'Arnasoy tumani, Istiqlol ko\'chasi 12', 'region_id' => 2, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Raxmatullayeva Zulfiya Ilhomovna', 'birth_date' => '2005-07-16', 'gender' => 'Ayol', 'address' => 'Baxmal tumani, Do\'stlik ko\'chasi 4', 'region_id' => 3, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Xasanov Shoxrux Alisher o\'g\'li', 'birth_date' => '2002-12-01', 'gender' => 'Erkak', 'address' => "G'allaorol tumani, Bog' ko'chasi 17", 'region_id' => 4, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishlamoqda', 'risk_level' => "O'rta xavf"],
            ['full_name' => 'Nematov Elbek Tulkinovich', 'birth_date' => '2003-09-10', 'gender' => 'Erkak', 'address' => "Do'stlik tumani, Zarafshon ko'chasi 23", 'region_id' => 5, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Yuqori xavf'],
            ['full_name' => 'Sobirova Dildora Rustamovna', 'birth_date' => '2004-06-20', 'gender' => 'Ayol', 'address' => 'Sharof Rashidov tumani, Yangi asr 8', 'region_id' => 6, 'education_status' => "O'qimoqda", 'employment_status' => 'Ishsiz', 'risk_level' => 'Past xavf'],
            ['full_name' => 'Baxtiyorov Sanjar Erkinovich', 'birth_date' => '2001-04-14', 'gender' => 'Erkak', 'address' => 'Zomin tumani, Chorbog\' ko\'chasi 16', 'region_id' => 7, 'education_status' => 'Bitirgan', 'employment_status' => 'Ishsiz', 'risk_level' => "O'rta xavf"],
        ];

        // Category assignments
        $categoryMap = [
            1 => [1, 3],
            2 => [5],
            3 => [3, 6],
            4 => [1, 4],
            5 => [7],
            6 => [2, 8],
            7 => [5, 7],
            8 => [4],
            9 => [1, 3, 6],
            10 => [8],
            11 => [2],
            12 => [4, 8],
            13 => [5, 7],
            14 => [1, 6],
            15 => [3],
            16 => [7, 8],
            17 => [4],
            18 => [2, 6],
            19 => [5],
            20 => [1, 8],
        ];

        // Officer assignments
        $officerMap = [
            1 => [1],
            2 => [2],
            3 => [3],
            4 => [4],
            5 => [5],
            6 => [1],
            7 => [2],
            8 => [3],
            9 => [4],
            10 => [5],
            11 => [1],
            12 => [2],
            13 => [3],
            14 => [1, 4],
            15 => [2, 5],
            16 => [3],
            17 => [4],
            18 => [5],
            19 => [1],
            20 => [2, 3],
        ];

        foreach ($youths as $i => $data) {
            $youth = Youth::create($data);
            $index = $i + 1;

            if (isset($categoryMap[$index])) {
                $youth->categories()->attach($categoryMap[$index]);
            }

            if (isset($officerMap[$index])) {
                $youth->officers()->attach($officerMap[$index]);
            }
        }
    }
}
