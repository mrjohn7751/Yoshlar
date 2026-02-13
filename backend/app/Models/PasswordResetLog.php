<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PasswordResetLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'officer_id',
        'username',
        'ip_address',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function officer()
    {
        return $this->belongsTo(Officer::class);
    }
}
