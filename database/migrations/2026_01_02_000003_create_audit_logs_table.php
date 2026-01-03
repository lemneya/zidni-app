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
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('event_type')->comment('Type of event: login, logout, data_access, etc.');
            $table->string('entity_type')->nullable()->comment('Entity affected: User, DealFolder, Capture');
            $table->unsignedBigInteger('entity_id')->nullable()->comment('ID of affected entity');
            $table->string('action')->comment('Action performed: create, read, update, delete');
            $table->text('description')->nullable();
            $table->json('old_values')->nullable()->comment('Previous values before change');
            $table->json('new_values')->nullable()->comment('New values after change');
            $table->string('ip_address', 45)->nullable();
            $table->string('user_agent')->nullable();
            $table->string('request_id')->nullable()->comment('Unique request identifier');
            $table->timestamp('occurred_at')->useCurrent();
            $table->timestamps();

            // Indexes
            $table->index('user_id');
            $table->index('event_type');
            $table->index('entity_type');
            $table->index('entity_id');
            $table->index('action');
            $table->index('occurred_at');
            $table->index('request_id');

            // Composite indexes for common queries
            $table->index(['user_id', 'event_type']);
            $table->index(['entity_type', 'entity_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
