<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Region extends Model
{
    use HasFactory;

    protected $fillable = ['name'];

    public function officers()
    {
        return $this->hasMany(Officer::class);
    }

    public function youths()
    {
        return $this->hasMany(Youth::class);
    }
}
