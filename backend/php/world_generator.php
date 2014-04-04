<?php

// ---------------------------------------------------------------------------------------------------- //

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
		
		for ($i=0;$i<$seed['num_of_plots'];$i++) {
			$patch_count = 0;
			$num_of_patches = $seed['plot_dimensions']['width']*$seed['plot_dimensions']['height'];
			for($j=0;$j<$num_of_patches;$j++) { 
				$patch_is = rand($seed['qubit_range_patch']['min'],$seed['qubit_range_patch']['max']);
				if ($patch_is == 0) { 
					//$patch_layout[] = array('patch_is' => false);
				} elseif ($patch_is == 1) { 
					$patch_count++;
					$patch_coords = array(
						floor($j / $seed['plot_dimensions']['height']), 
						$j % $seed['plot_dimensions']['width']
					);

					$qubit_growth_rate = rand($seed['qubit_growth_rate']['min'],$seed['qubit_growth_rate']['max']);
					$total_qubits_in_patch = ($seed['qubit_range_plot']['factor']*$seed['qubit_range_plot']['base'])*(rand($seed['qubit_range_plot']['range'][0],$seed['qubit_range_plot']['range'][1]));
					$total_qubits_in_plot[] = $total_qubits_in_patch;
					$patch_layout[] = array(
						'patch_index' => $j,
						'patch_coords' => $patch_coords, 
						'qubit_growth_rate' => $qubit_growth_rate,
						'qubits_availible_in_patch' => $total_qubits_in_patch,
						'qubits_total_in_patch' => $total_qubits_in_patch,
					);
				}
			}
			
			$names_array = explode(",",file_get_contents('../csv/elements.csv'));
			$random_index = rand(0,sizeof($names_array)-1);
			$random_name = $names_array[$random_index];
			
			$world[] = array(
	    		"_id" => $world_collection.md5($world_collection.$i),
				"name" => $random_name,
	    		"index" => $i,
				"owner_id" => null,
	    		"plots_total_in_world" => $seed['num_of_plots'],
				"qubits_total_in_world" => 0,
				"date_generated_ep" => date('U'),
				"date_generated_hr" => date('r'),
				"plot_style" => array (
					"color" => array( hexGenerator(),hexGenerator() )
				),
				"plot_parameters" => array (
					"qubits_availible_in_plot" => array_sum($total_qubits_in_plot), 
			        "qubits_total_in_plot" => array_sum($total_qubits_in_plot),
			        "plot_dimensions" => array($seed['plot_dimensions']['width'],$seed['plot_dimensions']['height']),
					"plot_size" => $patch_count,
					"plot_layout" => $patch_layout
				)
	    	);

			$total_qubits_in_plot = array();
			$patch_layout = array();
		}
		if ($seed['publish'] == true) { 
			foreach($world as $k) { $total_qubits_in_world[] = $k['plot_parameters']['qubits_total_in_plot'];}
			$total_qubits_in_world_sum = array_sum($total_qubits_in_world);
				
			foreach($world as $k) { array_push($k['qubits_total_in_world'],$total_qubits_in_world_sum); }
			foreach($world as $k) { $collection->insert($k); }
			$collection->update(
				(object) array(),
				array('$set' => array('qubits_total_in_world' => $total_qubits_in_world_sum )),
				array("multiple" => true)
			);

			echo $world_collection. ' was created!'; 
		} 
		elseif ($seed['publish'] == false) { 
			//echo json_encode($world); // SINGLE
		}
		
	}
}

// ---------------------------------------------------------------------------------------------------- //`

function hexGenerator() {
	$hex_vals_array = array ( 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F ) ;
	for ($i=0;$i<7;$i++) { 
		$hex_array[] = $hex_vals_array[rand(0,sizeof($hex_vals_array))]; 
	}
	return implode(null,$hex_array);
}

// ---------------------------------------------------------------------------------------------------- //

worldGenerator($seed) ;

// ---------------------------------------------------------------------------------------------------- //

?>