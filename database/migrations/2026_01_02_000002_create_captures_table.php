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

            // Indexes
            $table->index('deal_folder_id');
            $table->index('user_id');
            $table->index('firebase_id');
            $table->index('captured_at');
            $table->index('followup_done');
            $table->index('source');
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
