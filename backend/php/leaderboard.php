<?php

// ---------------------------------------------------------------------------------------------------- //


$uid = $seed['body']['uid'];

// ERROR - NOT SET
if ($uid == "" || $uid == null) { $leader_board['error'] = "Cannot search: 'uid' is not defined." ; } else {

	// SEARCH FOR PLAYER
	$uid_find = $user_collection->find(array('_id' => $uid));
	foreach($uid_find as $k => $v) {
		$leader_board['player']['_id'] = $v['_id'];
		$leader_board['player']['name'] = $v['name'];
		$leader_board['player']['current_num_of_qubits'] = $v['current_num_of_qubits'];
	}
	
	if ($leader_board == null) { $leader_board['error'] = "Query Cancelled: player 'uid' could not be found." ; } else {

		// LIMIT LEADERS
		if (isset($seed['body']['num_of_leaders'])) { 
			$num_of_leaders = $seed['body']['num_of_leaders'];
		} else { 
			$num_of_leaders = 10;
		}

		// SORT ORDER
		$sort_order = $seed['body']['sort_order'];
		if (isset($sort_order) && $sort_order == 'most to least' || $sort_order == 'least to most') {
			if ($sort_order == 'most to least') { $sort_order_return = -1; }
			if ($sort_order == 'least to most') { $sort_order_return = 1; } 
		} else { 
			$sort_order_return = -1;
		}

		// QUERY
		$leaders_info = $user_collection->aggregate(
			array(
				array('$sort' => array("current_num_of_qubits" => $sort_order_return)),
				array('$limit' => $num_of_leaders)
			)
		);

		// RETURN
		$c = 0;
		foreach($leaders_info['result'] as $k => $v){
			$c++;
			$leader_board['leaders'][$c]['_id'] = $v['_id'];
			$leader_board['leaders'][$c]['name'] = $v['name'];
			$leader_board['leaders'][$c]['current_num_of_qubits'] = $v['current_num_of_qubits'];
		}
	}
}

echo json_encode($leader_board);

// ---------------------------------------------------------------------------------------------------- //

?>