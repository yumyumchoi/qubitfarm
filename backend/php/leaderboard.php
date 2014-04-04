<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

// ---------------------------------------------------------------------------------------------------- //

function leaderBoard($seed) {
	$database = $seed['database'];
	$user_collection_prefix = 'qfu'.$seed['world_index'];
	$world_collection_prefix = 'qfw'.$seed['world_index'];
	$user_id = $seed['uid'];
	
	$server = 'mongodb://'.$seed['username'].':'.$seed['password'].'@'.$seed['uri'].'/'.$database;
	$connection = new MongoClient($server);
	$user_collection = $connection->$database->$user_collection_prefix;
	$world_collection = $connection->$database->$world_collection_prefix;
	
	$user_info = $user_collection->find(array('_id' => $user_id));
	foreach($user_info as $k => $v) {
		$leader_board['player']['_id'] = $v['_id'];
		$leader_board['player']['name'] = $v['name'];
		$leader_board['player']['current_num_of_qubits'] = $v['current_num_of_qubits'];
	}

	if ($seed['sort_order'] == 'highest to lowest' || $seed['sort_order'] == 'lowest to highest') {
		if ($seed['sort_order'] == 'highest to lowest') { $sort_order = -1; }
		if ($seed['sort_order'] == 'lowest to highest') { $sort_order = 1; } 
	} else { echo json_encode(array("error" => "Unknown sort order.")); die; }
	$leaders_info = $user_collection->aggregate(
		array(
			array('$sort' => array("current_num_of_qubits" => $sort_order)),
			array('$limit' => $seed['num_of_leaders'])
		)
	);
	
	$c = 0;
	foreach($leaders_info['result'] as $k => $v){
		$c++;
		$leader_board['leaders'][$c]['_id'] = $v['_id'];
		$leader_board['leaders'][$c]['name'] = $v['name'];
		$leader_board['leaders'][$c]['current_num_of_qubits'] = $v['current_num_of_qubits'];
	}
	echo json_encode($leader_board);
}

// ---------------------------------------------------------------------------------------------------- //

leaderBoard($seed);

// ---------------------------------------------------------------------------------------------------- //

?>