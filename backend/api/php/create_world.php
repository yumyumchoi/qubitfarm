<?php

$collection_exists = 0;
$cursor = $world_collection->findOne(array());
foreach($cursor as $doc) { if(isset($doc)) { $collection_exists = 1; }}

if ($collection_exists == 1 && $seed['header']['publish'] == true) { echo $world_collection_prefix.' already exists!'; die; } else {
	
	for ($i=0;$i<$seed['body']['num_of_plots'];$i++) {
		$patch_count = 0;
		$num_of_patches = $seed['body']['plot_dimensions']['width']*$seed['body']['plot_dimensions']['height'];
		for($j=0;$j<$num_of_patches;$j++) { 
			$patch_is = rand($seed['body']['qubit_range_patch']['min'],$seed['body']['qubit_range_patch']['max']);
			if ($patch_is == 0) { 
				//$patch_layout[] = array('patch_is' => false);
			} elseif ($patch_is == 1) { 
				$patch_count++;
				$patch_coords = array(
					floor($j / $seed['body']['plot_dimensions']['height']), 
					$j % $seed['body']['plot_dimensions']['width']
				);

				$qubit_growth_rate = rand($seed['body']['qubit_growth_rate']['min'],$seed['body']['qubit_growth_rate']['max']);
				$total_qubits_in_patch = ($seed['body']['qubit_range_plot']['factor']*$seed['body']['qubit_range_plot']['base'])*(rand($seed['body']['qubit_range_plot']['range'][0],$seed['body']['qubit_range_plot']['range'][1]));
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
		
		$names_array = explode(",",file_get_contents($config['sources']['world_names']));
		$random_index = rand(0,sizeof($names_array)-1);
		$random_name = $names_array[$random_index];
		
		$world[] = array(
    		"_id" => $world_collection_prefix.md5($world_collection.$i),
			"name" => $random_name,
    		"index" => $i,
			"owner_id" => null,
    		"plots_total_in_world" => $seed['body']['num_of_plots'],
			"qubits_total_in_world" => 0,
			"date_generated_ep" => date('U'),
			"date_generated_hr" => date('r'),
			"plot_style" => array (
				"color" => array( hexGenerator(),hexGenerator() )
			),
			"plot_parameters" => array (
				"qubits_availible_in_plot" => array_sum($total_qubits_in_plot), 
		        "qubits_total_in_plot" => array_sum($total_qubits_in_plot),
		        "plot_dimensions" => array($seed['body']['plot_dimensions']['width'],$seed['body']['plot_dimensions']['height']),
				"plot_size" => $patch_count,
				"plot_layout" => $patch_layout
			)
    	);

		$total_qubits_in_plot = array();
		$patch_layout = array();
	}
	if ($seed['header']['publish'] == true) { 
		foreach($world as $k) { $total_qubits_in_world[] = $k['plot_parameters']['qubits_total_in_plot'];}
		$total_qubits_in_world_sum = array_sum($total_qubits_in_world);
			
		foreach($world as $k) { array_push($k['qubits_total_in_world'],$total_qubits_in_world_sum); }
		foreach($world as $k) { $world_collection->insert($k); }
		$world_collection->update(
			(object) array(),
			array('$set' => array('qubits_total_in_world' => $total_qubits_in_world_sum )),
			array("multiple" => true)
		);
		
		$success_message = array(
						"success" => array(
							"world_db" => $world_collection_prefix. ' was created!',
							"user_db" => $user_collection_prefix. ' was created!'
						)
					); 
					
		echo json_encode($success_message);
	} 
	elseif ($seed['header']['publish'] == false) { 
		echo json_encode($world); // SINGLE
	}
	
}

?>