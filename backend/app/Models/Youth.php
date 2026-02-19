<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
     */
    public function setPhotoAttribute($value): void
    {
        if (is_string($value) && str_contains($value, '/')) {
            $this->attributes['photo'] = $value;
        } else {
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
