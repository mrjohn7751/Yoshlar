<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCommentRequest;
use App\Http\Resources\CommentResource;
use App\Models\Activity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    public function index(Request $request, Activity $activity): JsonResponse
    {
        $query = $activity->comments()
            ->with('user')
            ->latest();

        if ($request->boolean('all')) {
            return response()->json([
                'data' => CommentResource::collection($query->get()),
            ]);
        }

        $comments = $query->paginate(20);

        return response()->json(CommentResource::collection($comments)->response()->getData(true));
    }

    public function store(StoreCommentRequest $request, Activity $activity): JsonResponse
    {
        $comment = $activity->comments()->create([
            'body' => $request->body,
        ]);
        $comment->user_id = auth()->id();
        $comment->save();

        $comment->load('user');

        return response()->json([
            'message' => 'Izoh muvaffaqiyatli qo\'shildi.',
            'data' => new CommentResource($comment),
        ], 201);
    }
}
