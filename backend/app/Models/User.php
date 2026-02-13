<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'phone',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function isRahbariyat(): bool
    {
        return $this->role === 'rahbariyat';
    }

    public function isMasul(): bool
    {
        return $this->role === 'masul';
    }

    public function officer()
    {
        return $this->hasOne(Officer::class);
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}
