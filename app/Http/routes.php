<?php

use function Itertools\zip;
use function Itertools\map;
/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::auth();

Route::group(['prefix' => '/api/v0.1', 'middleware'=> 'api'], function () {
    // route boilerpate
    Route::get('/states', function () {
        $file = base_path('resources/assets/states.json');
        $json = json_decode(file_get_contents($file), true);
        $states = $json['states'];
        $pairMap = map(function ($elem) {
            return [
                'code' => $elem[0],
                'name' => $elem[1]
            ];
        }, zip(array_keys($states), array_values($states)));

        return iterator_to_array($pairMap);
    });

    Route::get('/cities/{state}', function ($state) {
        $state = strtoupper($state);
        $file = base_path('resources/assets/cities.json');
        $json = json_decode(file_get_contents($file), true);
        $cities = $json['cities'];
        $citiesOnState = isset($cities[$state]) ? $cities[$state] : [];

        if (empty($citiesOnState)) {
            return $citiesOnState;
        } else {
            $pairMap = map(function ($elem) {
                return [
                    'code' => $elem[0],
                    'name' => $elem[1]
                ];
            }, zip(array_keys($citiesOnState), array_values($citiesOnState)));

            return iterator_to_array($pairMap);
        }
    });
});

Route::get('/home', 'HomeController@index');
