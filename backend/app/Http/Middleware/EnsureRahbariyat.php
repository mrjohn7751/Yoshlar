<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRahbariyat
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || !$request->user()->isRahbariyat()) {
            return response()->json(['message' => 'Faqat rahbariyat uchun ruxsat berilgan.'], 403);
        }

        return $next($request);
    }
}
