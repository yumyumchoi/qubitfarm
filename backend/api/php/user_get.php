<?php

// ---------------------------------------------------------------------------------------------------- //

$uid = $seed['body']['uid'];

// ERROR - NOT SET
if ($uid == "" || $uid == null) { echo "Cannot search: 'uid' is not defined" ; die; } else {

	if (is_array($uid)) { 
		
		// MULTI
		foreach($uid as $uids) {
			$user_info = $user_collection->find(array("_id" => $uids));
	
			foreach($user_info as $k => $v) {
				$user_search[] = $v;
			}
		}
	
	} else {
	
		// SINGLE
		$user_info = $user_collection->find(array("_id" => $uid));
		foreach($user_info as $k => $v) { $user_search[] = $v; }
	}

	// ERROR - NOT FOUND
	if ($user_search == null) { $user_search['error'] = "User not found" ; }
	
}

echo json_encode($user_search);

// ---------------------------------------------------------------------------------------------------- //

?>