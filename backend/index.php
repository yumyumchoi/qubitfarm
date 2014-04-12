<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

$database = "qubitfarm";
$username = "qubitfarmer";
$password = "killmedaddy";
$uri = "ds031347.mongolab.com:31347";
$server = 'mongodb://'.$username.':'.$password.'@'.$uri.'/'.$database;
$connection = new MongoClient($server);
$header = $seed['header'];
$body = $seed['body'];

$world_index = $seed['header']['world_index'];

$user_collection_prefix = 'qfu'.$world_index;
$world_collection_prefix = 'qfw'.$world_index;

$user_collection = $connection->$database->$user_collection_prefix;
$world_collection = $connection->$database->$world_collection_prefix;

// ---------------------------------------------------------------------------------------------------- //

function getOne($theCollection) {
	$get_one = $theCollection->findOne(array());
	return $get_one;
}

// ---------------------------------------------------------------------------------------------------- //

function hexGenerator() {
	$hex_vals_array = array ( 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F ) ;
	for ($i=0;$i<7;$i++) { 
		$hex_array[] = $hex_vals_array[rand(0,sizeof($hex_vals_array))]; 
	}
	return implode(null,$hex_array);
}

// ---------------------------------------------------------------------------------------------------- //

// CHECK FOR WORLD
if ($header['method'] == "create world") { } else {
	if (getOne($user_collection) == null) {
		$query_result['error'] = "User collection ".$world_index." does not exists" ; 
	}
	if (getOne($world_collection) == null) {
		$query_result['error'] = "World collection ".$world_index." does not exists" ;
	}
}

// CHECK HEADERS
$request_array = array("get user","get plots","leaderboard","create world","create user");
if (!in_array($header['method'],$request_array)) { $query_result['error'] = "Unknown method '".$header['method']. "'. Use => '".implode("','",$request_array)."'" ; }

// CHECK BODY
if (isset($body) || $header['method'] == "create user") { } else { $query_result['error'] = "Parameters of 'body' are either undefined or malformed." ; } 

// ERROR MESSAGE
if (isset($query_result)) { echo json_encode($query_result); die; } 

// ---------------------------------------------------------------------------------------------------- //

// CALL METHODS
if ($header['method'] == "get user") { include('php/user_get.php'); }
if ($header['method'] == "leaderboard") { include('php/leaderboard.php'); }
if ($header['method'] == "create user") { include('php/user_generator.php'); }
if ($header['method'] == "create world") { include('php/world_generator.php'); }

// ---------------------------------------------------------------------------------------------------- //
	
?>