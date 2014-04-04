<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

// ---------------------------------------------------------------------------------------------------- //

function userGenerator($seed) {
	$database = $seed['database'];
	$user_collection_prefix = $seed['user_prefix'].$seed['world_index'];
	$world_collection_prefix = 'qfw'.$seed['world_index'];
	$server = 'mongodb://'.$seed['username'].':'.$seed['password'].'@'.$seed['uri'].'/'.$database;
	$connection = new MongoClient($server);
	$user_collection = $connection->$database->$user_collection_prefix;
	$world_collection = $connection->$database->$world_collection_prefix;

	$current_index = $user_collection->count();
	$world_count = $world_collection->count();

	$plot_search = $world_collection->find(array("owner_id" => null));
	foreach($plot_search as $k => $v) {
		$first_plot_id = $v['_id'];
		$first_plot_qubits = $v["plot_parameters"]["qubits_total_in_plot"];
		break;
	}
	
	if ($first_plot_id == null) { echo json_encode(array("error" => "No plots left in world.")); die; }
	$new_uid = $user_collection_prefix.md5($user_collection_prefix.$current_index);
	
	$names_array = explode(",",file_get_contents('../csv/simpsons.csv'));
	$random_index = rand(0,sizeof($names_array)-1);
	$random_name = $names_array[$random_index];

	$user = array(
		"_id" => $new_uid,
		"name" => $random_name,
		"user_index" => $current_index,
		"world_collection" => $world_collection_prefix,
		"current_num_of_qubits" => $first_plot_qubits, 
		"plots" => array(
			(object) array(
				"date_added_ep" => date("U"),
				"date_generated_hr" => date("r"),
	            "plot_id" => $first_plot_id
			)
		)
	);
	
	$user_collection->insert($user); 	
	$world_collection->update(
		array("_id" => $first_plot_id),
		array('$set' => array(
			"owner_id" => $new_uid
			)
		)
	); 
	 
	echo json_encode($user);
	
}
// ---------------------------------------------------------------------------------------------------- //

userGenerator($seed);

// ---------------------------------------------------------------------------------------------------- //
	
?>