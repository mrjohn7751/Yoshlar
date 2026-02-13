<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'result',
        'date',
        'status',
        'latitude',
        'longitude',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
        ];
    }

    public function youth()
    {
        return $this->belongsTo(Youth::class);
    }

    public function officer()
    {
        return $this->belongsTo(Officer::class);
    }

    public function images()
    {
        return $this->hasMany(ActivityImage::class);
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}
