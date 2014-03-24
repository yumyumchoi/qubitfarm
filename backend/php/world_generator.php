<?php

// ---------------------------------------------------------------------------------------------------- //

header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

// ---------------------------------------------------------------------------------------------------- //

function worldGenerator($seed) {
	$world_database = $seed['database'];
	$world_collection = $seed['world_prefix'].$seed['world_index'];
	$server = 'mongodb://'.$seed['username'].':'.$seed['password'].'@'.$seed['uri'].'/'.$world_database;
	$connection = new MongoClient($server);
	$collection = $connection->$world_database->$world_collection;
	
	$collection_exists = 0;
	$cursor = $collection->findOne(array());
	foreach($cursor as $doc) { if(isset($doc)) { $collection_exists = 1; }}
	
	if ($collection_exists == 1) { echo $world_collection.' already exists!'; die; } else {
	
		$seed_array = seedGen($seed);
		for ($i=0;$i<sizeof($seed_array);$i++) {
	    	$world = array(
	    		"_id" => $world_collection.md5($world_collection.$i),
				"date_generated" => date('r'),
				"info" => array(
					"plot_name" => $seed_array[$i],
					"plot_style" => array (
						"background_color_rbg" => array(133,233,333),
						"color_rbg" => array(244,12,32)
					),
				),
				"parameters" => array (
					"bonus_probability" => array(1,1000),
			        "patch_total" => 9, 
			        "qubits_availible" => 6478, 
			        "qubits_total" => 10000, 
			        "plot_value" => 5000,
					"plot_layout" => array(
						"patch_dimensions" => array(3,3),
						"patch_attributes" => array(0,20,100,20,0,20,60,120,120)
					)
				)
			
	    	);
		
			$collection->insert($world);
		}
		echo $world_collection. ' was created!';
	}
}

// ---------------------------------------------------------------------------------------------------- //`

function seedGen($seed) {
	if (isset($seed['gen_method'])) {
		if (isset($seed['gen_method']['top_ten_crit_url'])) {
			$clean_url = stripslashes($seed['gen_method']['top_ten_crit_url']);
			$top_ten_crit_string = shell_exec('../sh/./get_crit_colletion_title.sh '.$clean_url);
			$top_ten_crit_array = explode("\n",$top_ten_crit_string);
			return array_filter($top_ten_crit_array);
		}
		if (isset($seed['gen_method']['num_of_seeds'])) {
			for($i=0;$i<$seed['gen_method']['num_of_seeds'];$i++) { $seed_num_array[] = $i ; }
			return $seed_num_array;	
		}
	} else {
		echo "No generation method found.";
		die;
	}
}

// ---------------------------------------------------------------------------------------------------- //

worldGenerator($seed) ;

// ---------------------------------------------------------------------------------------------------- //

?>