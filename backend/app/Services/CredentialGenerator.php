<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Str;

class CredentialGenerator
{
    /**
     * Generate a username from a full name (Uzbek format: Surname Firstname).
     * Format: firstname.surname (lowercase, transliterated)
     */
    public function fromFullName(string $fullName): string
    {
        $parts = preg_split('/\s+/', trim($fullName));

        if (count($parts) >= 2) {
            $surname = $parts[0];
            $firstname = $parts[1];
        } else {
            $surname = $parts[0];
            $firstname = '';
        }

        $username = $firstname ? strtolower($firstname . '.' . $surname) : strtolower($surname);
        $username = $this->transliterate($username);

        return $this->ensureUnique($username);
    }

    /**
     * Generate a random password.
     */
    public function generatePassword(): string
    {
        return Str::random(12);
    }

    /**
     * Transliterate Uzbek characters to ASCII.
     */
    private function transliterate(string $value): string
    {
        $map = [
            "o'" => 'o',
            "g'" => 'g',
            "O'" => 'O',
            "G'" => 'G',
            "'" => '',
            'sh' => 'sh',
            'ch' => 'ch',
            "o`" => 'o',
            "g`" => 'g',
            "`" => '',
        ];

        $value = str_replace(array_keys($map), array_values($map), $value);

        // Remove any remaining non-alphanumeric characters except dots
        $value = preg_replace('/[^a-z0-9.]/', '', $value);

        return $value;
    }

    /**
     * Ensure the username is unique by appending a number if needed.
     */
    private function ensureUnique(string $username): string
    {
        $base = $username;
        $counter = 1;

        while (User::where('username', $username)->exists()) {
            $username = $base . $counter;
            $counter++;
        }

        return $username;
    }
}
