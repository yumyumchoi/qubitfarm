<?php

// ---------------------------------------------------------------------------------------------------- //

$current_index = $user_collection->count();
$world_count = $world_collection->count();

$plot_search = $world_collection->find(array("owner_id" => null));
foreach($plot_search as $k => $v) {
	$first_plot_id = $v['_id'];
	$first_plot_name = $v['name'];
	$first_plot_qubits = $v["plot_parameters"]["qubits_total_in_plot"];
	break;
}

if ($first_plot_id == null) { echo "No plots left in world."; die; }
$new_uid = $user_collection_prefix.md5($user_collection_prefix.$current_index);

$names_array = explode(",",file_get_contents($config['sources']['user_names']));
$random_index = rand(0,sizeof($names_array)-1);
if (isset($seed['body']['name'])) { $name = $seed['body']['name'] ; } else { $name = $names_array[$random_index]; }

$user = array(
	"_id" => $new_uid,
	"name" => $name,
	"index" => $current_index,
	"world_collection" => $world_collection_prefix,
	"current_num_of_qubits" => $first_plot_qubits, 
	"plots" => array(
		(object) array(
			"date_added_ep" => date("U"),
			"date_generated_hr" => date("r"),
            "plot_id" => $first_plot_id,
			"plot_name" => $first_plot_name,
			"plot_qubits" => $first_plot_qubits
		)
	)
);

$user_collection->insert($user); 	
$world_collection->update(array( "_id" => $first_plot_id ),array( '$set' => array( "owner_id" => $new_uid )));
 
echo json_encode($user);

// ---------------------------------------------------------------------------------------------------- //

?>