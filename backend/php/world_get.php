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

$query = array();

// FILTER
if (isset($seed['user_search'])) {
	if ($seed['user_search'] == 'all' || $seed['user_search'] == 'owned' || $seed['user_search'] == 'unowned') { 
		if ($seed['user_search'] == 'all') { }
		if ($seed['user_search'] == 'unowned') { $query[] = array('$match' => array("owner_id" => null)) ; }
		if ($seed['user_search'] == 'owned') { $query[] = array('$match' => array("owner_id" => array('$regex' => '.*'))) ; }
	} else {
		$query[] = array('$match' => array("owner_id" => $seed['user_search'])) ;
	}
} else {
	
}

// SORT
if (isset($seed['sortby'])) {
	$sort_get = $seed['sortby']; $sort = explode(",",$sort_get);
	$sort_by = $sort[0]; if ($sort_by == "qubits") { 
		$sort_by = "plot_parameters.qubits_availible_in_plot"; 
	}
	if ($sort[1] == 'most to least') { $sort_order = -1 ; }
	if ($sort[1] == 'least to most') { $sort_order = 1 ; } 
	$query[] = array('$sort' => array($sort_by => $sort_order));
} else { 
	$query[] = array('$sort' => array("plot_parameters.qubits_availible_in_plot" => -1));
}

// SKIP
$default_skip = 0;
if (isset($seed['start'])) {
	if (is_numeric($seed['start'])) {
		$query[] = array('$skip' => $seed['start']);
	} else {
		$error_msg = "The value for 'start' must be an integer.";
		echo json_encode(array("error" => $error_msg)); die;
	}
} else {
	$query[] = array('$skip' => $default_skip);
}

// LIMIT
$default_limit = 8;
if (isset($seed['limit'])) {
	if ($seed['limit'] == "none") { 
		$plot_get_one = $world_collection->findOne(array());
		$plot_count = $plot_get_one['plots_total_in_world'];
		$query[] = array('$limit' => $plot_count);
	} else {
		if (is_numeric($seed['limit'])) {
			$query[] = array('$limit' => $seed['limit']);
		} else {
			$error_msg = "The value for 'limit' must be an integer or operator like 'none'.";
			echo json_encode(array("error" => $error_msg)); die;
		}
	}
} else {
	$query[] = array('$limit' => $default_limit);
}

$query = array_values($query);

$plots = $world_collection->aggregate($query);

// RETURN
$c = 0;
foreach($plots['result'] as $k => $v) {
	$c++;
	$plot_result[$c]['pid'] = $v['_id'];
	$plot_result[$c]['name'] = $v['name'];
	$plot_result[$c]['index'] = $v['index'];
	$plot_result[$c]['owner_id'] = $v['owner_id'];
	$plot_result[$c]['plots_total_in_world'] = $v['plots_total_in_world'];
	$plot_result[$c]['date_generated_ep'] = $v['date_generated_ep'];
	$plot_result[$c]['date_generated_hr'] = $v['date_generated_hr'];
	$plot_result[$c]['color'] = $v['plot_style']['color'];
	$plot_result[$c]['qubits_availible_in_plot'] = $v['plot_parameters']['qubits_availible_in_plot'];
	$plot_result[$c]['qubits_total_in_plot'] = $v['plot_parameters']['qubits_total_in_plot'];
	//$plot_result[$c]['plot_dimensions'] = $v['plot_parameters']['plot_dimensions'];
	$plot_result[$c]['num_of_patches'] = $v['plot_parameters']['plot_size	'];
	//$plot_result[$c]['plot_layout'] = $v['plot_parameters']['plot_layout'];
}

echo json_encode($plot_result);

// ---------------------------------------------------------------------------------------------------- //

?>