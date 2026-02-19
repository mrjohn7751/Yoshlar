<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

class Youth extends Model
{
    use HasFactory;

    protected $fillable = [
        'full_name',
        'phone',
        'photo',
        'birth_date',
        'gender',
        'address',
        'region_id',
        'education_status',
        'employment_status',
        'risk_level',
        'description',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
        ];
    }

    /**
     * Photo maydoniga faqat haqiqiy fayl yo'lini saqlash.
     * "0", "1", bo'sh string kabi noto'g'ri qiymatlarni rad etadi.
     */
    public function setPhotoAttribute($value): void
    {
        if ($value === null) {
            $this->attributes['photo'] = null;
        } elseif (is_string($value) && str_contains($value, '/')) {
            $this->attributes['photo'] = $value;
        } else {
            Log::warning('Youth photo: noto\'g\'ri qiymat rad etildi', [
                'value' => $value,
                'type' => gettype($value),
                'trace' => collect(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 5))
                    ->map(fn($f) => ($f['class'] ?? '') . '::' . ($f['function'] ?? '') . ':' . ($f['line'] ?? ''))
                    ->toArray(),
            ]);
            $this->attributes['photo'] = null;
        }
    }

    public function region()
    {
        return $this->belongsTo(Region::class);
    }

    public function categories()
    {
        return $this->belongsToMany(Category::class, 'youth_category')->withTimestamps();
    }

    public function officers()
    {
        return $this->belongsToMany(Officer::class, 'youth_officer')->withTimestamps();
    }

    public function activities()
    {
        return $this->hasMany(Activity::class);
    }
}
