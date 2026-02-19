<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Officer extends Model
{
    use HasFactory;

    protected $fillable = [
        'full_name',
        'position',
        'region_id',
        'phone',
        'photo',
    ];

    /**
     * Photo maydoniga faqat haqiqiy fayl yo'lini saqlash.
     */
    public function setPhotoAttribute($value): void
    {
        if ($value === null) {
            $this->attributes['photo'] = null;
        } elseif (is_string($value) && str_contains($value, '/')) {
            $this->attributes['photo'] = $value;
        } else {
            $this->attributes['photo'] = null;
        }
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function region()
    {
        return $this->belongsTo(Region::class);
    }

    public function youths()
    {
        return $this->belongsToMany(Youth::class, 'youth_officer')->withTimestamps();
    }

    public function activities()
    {
        return $this->hasMany(Activity::class);
    }
}
