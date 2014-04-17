<?php

$user_id = $seed['body']['user_id'];
$plot_id = $seed['body']['plot_id'];

// CHECK TO SEE IF USER EXISTS AND GET INFO
$user_find = $user_collection->find(array('_id' => $user_id));
foreach($user_find as $k => $v) {
	$user_info['user']['_id'] = $v['_id'];
	$user_info['user']['name'] = $v['name'];
	$user_info['user']['current_num_of_qubits'] = $v['current_num_of_qubits'];
}
if ($user_info == null) { echo "Player '".$user_id."' does not exist." ; die; } else {
	
	// CHECK TO SEE IF PLOT IS EXISTS
	$plot_find = $world_collection->find(array('_id' => $plot_id));
	foreach($plot_find as $k => $v) {
		$plot_info['plot']['_id'] = $v['_id'];
		$plot_info['plot']['name'] = $v['name'];
		$plot_info['plot']['owner_id'] = $v['owner_id'];
		$plot_info['plot']['qubits_availible_in_plot'] = $v['plot_parameters']['qubits_availible_in_plot'];
	}
	if ($plot_info == null) { echo "Plot '".$plot_id."' does not exist." ; die; } else {
		
		// CHECK TO SEE IF PLOT IS ALREADY OWNED
		if ($plot_info['plot']['owner_id'] != null) { echo "Plot '".$plot_id."' is already owned by '".$plot_info['plot']['owner_id']."'." ; die; } else {
		
			// BIND USER ID TO PLOT
			$world_collection->update(
				array('_id' => $plot_id),
				array('$set' => array('owner_id' => $user_id))
			);
			
			// ADD CHECK TO INSURE USER WAS SUCCESSFULLY BOUND TO PLOT
					
			// ADD PLOT INFO TO USER
			$user_collection->update(
				array('_id' => $user_id),
				array('$push' => array(
					"plots" => array(
						"date_added_ep" => date("U"),
						"date_generated_hr" => date("r"),
			            "plot_id" => $plot_id,
						"plot_name" => $plot_info['plot']['name'],
						"plot_qubits" => $plot_info['plot']['qubits_availible_in_plot']
					)	
				))
			);
			
			// ADD PLOT QUBITS TO USER QUBITS
			$user_collection->update(
				array('_id' => $user_id),
				array('$set' => array(
					'current_num_of_qubits' => 
						($user_info['user']['current_num_of_qubits']+$plot_info['plot']['qubits_availible_in_plot'])
				))
			);
			
			// GET UPDATE ON USER
			$user_find = $user_collection->find(array('_id' => $user_id));
			foreach($user_find as $k => $v) {
				$user_info_updated = $v ;
			}
			
			// PRINT RESULTS
			echo json_encode($user_info_updated);
			
		}
	}
}
	
?>