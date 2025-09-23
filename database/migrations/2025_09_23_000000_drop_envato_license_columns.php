<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('global_settings')) {
            Schema::table('global_settings', function (Blueprint $table) {
                foreach (['purchase_code', 'supported_until', 'last_license_verified_at', 'license_type'] as $column) {
                    if (Schema::hasColumn('global_settings', $column)) {
                        $table->dropColumn($column);
                    }
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('global_settings')) {
            Schema::table('global_settings', function (Blueprint $table) {
                if (!Schema::hasColumn('global_settings', 'purchase_code')) {
                    $table->string('purchase_code', 80)->nullable();
                }
                if (!Schema::hasColumn('global_settings', 'supported_until')) {
                    $table->timestamp('supported_until')->nullable();
                }
                if (!Schema::hasColumn('global_settings', 'last_license_verified_at')) {
                    $table->timestamp('last_license_verified_at')->nullable()->default(null);
                }
                if (!Schema::hasColumn('global_settings', 'license_type')) {
                    $table->string('license_type')->nullable();
                }
            });
        }
    }
};


