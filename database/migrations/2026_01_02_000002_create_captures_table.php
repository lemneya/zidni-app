<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('captures', function (Blueprint $table) {
            $table->id();
            $table->foreignId('deal_folder_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->text('transcript');
            $table->string('audio_file_path')->nullable()->comment('Path to stored audio file');
            $table->string('firebase_id')->unique()->nullable()->comment('Firestore document ID for sync');
            $table->timestamp('captured_at');
            $table->boolean('followup_done')->default(false);
            $table->timestamp('followup_done_at')->nullable();
            $table->string('source')->default('online')->comment('online or offline');
            $table->json('metadata')->nullable()->comment('Additional capture metadata');
            $table->timestamps();
            $table->softDeletes();

            // PERFORMANCE: Optimized indexes for common queries
            // Single column indexes
            $table->index('deal_folder_id');
            $table->index('user_id');
            $table->index('firebase_id');
            $table->index('captured_at');
            $table->index('followup_done');
            $table->index('source');

            // Composite indexes for query optimization
            // Folder timeline: ORDER BY captured_at DESC WHERE deal_folder_id = ?
            $table->index(['deal_folder_id', 'captured_at'], 'idx_folder_timeline');

            // User timeline: ORDER BY captured_at DESC WHERE user_id = ?
            $table->index(['user_id', 'captured_at'], 'idx_user_timeline');

            // Follow-up filter: WHERE user_id = ? AND followup_done = ?
            $table->index(['user_id', 'followup_done', 'captured_at'], 'idx_user_followup');

            // Offline queue: WHERE user_id = ? AND source = 'offline'
            $table->index(['user_id', 'source', 'captured_at'], 'idx_user_source');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('captures');
    }
};
