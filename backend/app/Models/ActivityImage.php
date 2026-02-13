<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActivityImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'path',
    ];

    public function activity()
    {
        return $this->belongsTo(Activity::class);
    }
}
