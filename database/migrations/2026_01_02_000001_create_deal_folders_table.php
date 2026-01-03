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
        Schema::create('deal_folders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('firebase_id')->unique()->nullable()->comment('Firestore document ID for sync');
            $table->timestamp('last_capture_at')->nullable();
            $table->integer('captures_count')->default(0);
            $table->boolean('is_archived')->default(false);
            $table->json('metadata')->nullable()->comment('Additional metadata');
            $table->timestamps();
            $table->softDeletes();

            // PERFORMANCE: Optimized indexes for common queries
            // Single column indexes
            $table->index('user_id');
            $table->index('firebase_id');
            $table->index('is_archived');
            $table->index('created_at');

            // Composite indexes for query optimization (order matters!)
            // Follow-up queue: ORDER BY last_capture_at DESC WHERE user_id = ?
            $table->index(['user_id', 'last_capture_at'], 'idx_user_last_capture');

            // Recent deals: ORDER BY created_at DESC WHERE user_id = ?
            $table->index(['user_id', 'created_at'], 'idx_user_created');

            // Search by name: WHERE user_id = ? AND name LIKE ?
            $table->index(['user_id', 'name'], 'idx_user_name');

            // Archived filter: WHERE user_id = ? AND is_archived = ?
            $table->index(['user_id', 'is_archived', 'created_at'], 'idx_user_archive_created');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('deal_folders');
    }
};
