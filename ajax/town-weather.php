<?php

header("Content-type:application/xml; charset=utf-8");

$towns = file_get_contents(dirname(__DIR__) . '/js/data/yr-capitals.json');
$towns = json_decode($towns);

$aTown = $towns[rand(0, count($towns) - 1)];

$url = $aTown[count($aTown) - 1];

$response = file_get_contents($url);
echo $response;