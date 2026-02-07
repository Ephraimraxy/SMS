<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class UpdateSystemNameToBurstBrain extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Update settings table
        DB::table('settings')->where('type', 'system_name')->update(['description' => 'BURST BRAIN ACADEMY']);
        DB::table('settings')->where('type', 'system_title')->update(['description' => 'BBA']);
        
        // Update admin user name
        DB::table('users')->where('name', 'CJ Inspired')->update(['name' => 'Burst Brain Admin']);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Revert settings table
        DB::table('settings')->where('type', 'system_name')->update(['description' => 'CJ INSPIRED ACADEMY']);
        DB::table('settings')->where('type', 'system_title')->update(['description' => 'CJIA']);
        
        // Revert admin user name
        DB::table('users')->where('name', 'Burst Brain Admin')->update(['name' => 'CJ Inspired']);
    }
}
