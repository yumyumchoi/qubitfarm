<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$config = json_decode(file_get_contents('json/config.json'),true);
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

$database = $config['database']['name'];;
$username = $config['database']['username'];;
$password = $config['database']['password'];;
$uri = $config['database']['uri'];;
$server = 'mongodb://'.$username.':'.$password.'@'.$uri.'/'.$database;
$connection = new MongoClient($server);
$header = $seed['header'];
$body = $seed['body'];

$world_index = $seed['header']['world_index'];
$world_collection_prefix = $config['vars']['world_prefix'].$world_index;
$user_collection_prefix = $config['vars']['user_prefix'].$world_index;

$user_collection = $connection->$database->$user_collection_prefix;
$world_collection = $connection->$database->$world_collection_prefix;

$method = $header['method'];

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

// CHECK BODY
if (isset($body) || $method == "create user") { } else { echo "Parameters of 'body' are either undefined or malformed." ; die; } 

// CHECK HEADERS
$request_array = array("get user","get plots","leaderboard","create world","create user");
if (!in_array($method,$request_array)) { echo "Unknown method '".$method. "'. Use => '".implode("','",$request_array)."'" ;die; }

// CHECK FOR WORLD
if ($method == "create world") { } else {
	if (getOne($world_collection) == null) {
		echo "World collection ".$world_index." does not exist or is empty" ; die;
	}
	if (getOne($user_collection) == null) {
		if ($method == "create user") { } else {
			echo "User collection ".$world_index." does not exist or is empty" ; die;
		}
	}
}

// ---------------------------------------------------------------------------------------------------- //

// CALL METHODS
if ($method == "get user") { include('php/user_get.php'); }
if ($method == "get plots") { include('php/world_get.php'); }
if ($method == "leaderboard") { include('php/leaderboard.php'); }
if ($method == "create user") { include('php/user_generator.php'); }
if ($method == "create world") { include('php/world_generator.php'); }

// ---------------------------------------------------------------------------------------------------- //
	
?>