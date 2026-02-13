<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureMasul
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || !$request->user()->isMasul()) {
            return response()->json(['message' => 'Faqat masul uchun ruxsat berilgan.'], 403);
        }

        return $next($request);
    }
}
