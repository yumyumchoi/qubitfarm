<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

// ---------------------------------------------------------------------------------------------------- //

$database = $seed['database'];
$user_collection_prefix = $seed['user_prefix'].$seed['world_index'];
$world_collection_prefix = 'qfw'.$seed['world_index'];
$server = 'mongodb://'.$seed['username'].':'.$seed['password'].'@'.$seed['uri'].'/'.$database;
$connection = new MongoClient($server);
$user_collection = $connection->$database->$user_collection_prefix;
$world_collection = $connection->$database->$world_collection_prefix;

$uid = $seed['uid'];
$user_info = $user_collection->find(array("_id" => $uid));

foreach($user_info as $k => $v) {
	$id = $v['_id'];
	$name = $v['name'];
	$index = $v['index'];
	$world = $v['world_collection'];
	$current_num_of_qubits = $v['current_num_of_qubits'];
	$plots = $v['plots'];
}

echo json_encode($v);

// ---------------------------------------------------------------------------------------------------- //

?>