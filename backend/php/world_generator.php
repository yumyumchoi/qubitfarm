<?php

// ---------------------------------------------------------------------------------------------------- //

//header('Content-type: application/json');
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
	
	if ($collection_exists == 1 && $seed['publish'] == true) { echo $world_collection.' already exists!'; die; } else {
		$seed_array = seedGen($seed);
		for ($i=0;$i<sizeof($seed_array);$i++) {
			
			$total_qubits = ($seed['qubit_range_plot']['factor']*$seed['qubit_range_plot']['base'])*(rand($seed['qubit_range_plot']['range'][0],$seed['qubit_range_plot']['range'][1]));
			$num_of_patches = rand($seed['plot_scale']['min'],$seed['plot_scale']['max']);
			
			for($j=0;$j<$num_of_patches;$j++) { 
				
				$patch_is = rand($seed['qubit_range_patch']['min'],$seed['qubit_range_patch']['max']);
				$qubit_growth_rate = rand($seed['quit_growth_rate']['min'],$seed['quit_growth_rate']['max']);
				
				if ($patch_is == 0) { 
					$patch_layout[] = array('patch_is' => false);
				} elseif ($patch_is == 1) { 
					$patch_layout[] = array('patch_is' => true, 'qubit_growth_rate' => $qubit_growth_rate);
				}
				
			}

			$world = array(
	    		"_id" => $world_collection.md5($world_collection.$i),
	    		"index" => $i,
	    		"size_of_world" => $seed['num_of_plots'],
				"date_generated" => date('r'),
				"info" => array(
					"plot_name" => $seed_array[$i],
					"plot_style" => array (
						"background_color_rbg" => array(133,233,333),
						"color_rbg" => array(244,12,32)
					),
				),
				"parameters" => array (
					"bonus_probability" => array($seed['bonus_probability']['min'],rand($seed['bonus_probability']['max'], $seed['bonus_probability'][1])),
			        "qubits_availible" => $total_qubits, 
			        "qubits_total" => $total_qubits,
			        "plot_dimensions" => array('width' => $seed['plot_dimensions']['width'],'height' => $seed['plot_dimensions']['height']),
					"plot_size" => $num_of_patches,
					"plot_layout" => $patch_layout
				)
	    	);
	    	
			if ($seed['publish'] == true) { $collection->insert($world); } elseif ($seed['publish'] == false) { echo json_encode($world); }
			$patch_layout = array();
		}
		
		if ($seed['publish'] == true) { echo $world_collection. ' was created!'; } elseif ($seed['publish'] == false) { }
		
	}
}

// ---------------------------------------------------------------------------------------------------- //`

function seedGen($seed) {
	if (isset($seed)) {
		if (isset($seed['top_ten_crit_url'])) {
			$clean_url = stripslashes($seed['top_ten_crit_url']);
			$top_ten_crit_string = shell_exec('../sh/./get_crit_colletion_title.sh '.$clean_url);
			$top_ten_crit_array = explode("\n",$top_ten_crit_string);
			return array_filter($top_ten_crit_array);
		}
		if (isset($seed['num_of_plots'])) {
			for($i=0;$i<$seed['num_of_plots'];$i++) { $seed_num_array[] = $i ; }
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