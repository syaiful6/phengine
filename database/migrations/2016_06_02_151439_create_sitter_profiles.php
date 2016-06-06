<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateSitterProfiles extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sitter_profiles', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('user_id')->index();
            $table->text('image');
            $table->string('address', 200);
            $table->string('zip', 100);
            $table->string('city', 200);
            $table->string('state', 200);
            $table->string('mobile_phone');
            $table->integer('available_weekdays');
            $table->integer('available_weekends');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('users');
    }
}
