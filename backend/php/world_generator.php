<?php
//header('Content-type: application/json');
date_default_timezone_set('America/New_York');
$json_request = file_get_contents('php://input');
$seed = json_decode($json_request,true);

// ---------------------------------------------------------------------------------------------------- //

function worldGenerator($seed) {
	$world_database = $seed['database'];
	$world_collection = 'world'.$seed['world_num'];
	$connection = new MongoClient();
	$collection = $connection->$world_database->$world_collection;
	
	$collection_exists = 0;
	$cursor = $collection->findOne(array());
	foreach($cursor as $doc) { if(isset($doc)) { $collection_exists = 1; }}
	
	if ($collection_exists == 1) { echo $world_collection.' already exists!'; die; } else {
	
		$seed_array = seedGen($seed);
		for ($i=0;$i<sizeof($seed_array);$i++) {
	    	$world = array(
	    		"_id" => $seed['world_code'].'-'.md5($seed['patch_gen_salt'].$i),
				"date_generated" => date('r'),
				"info" => array(
					"patch_name" => $seed_array[$i],
					"patch_style" => array (
						"background_color_rbg" => array(133,233,333),
						"color_rbg" => array(244,12,32)
					),
				),
				"parameters" => array (
					"bonus_probability" => array(1,1000),
			        "num_of_patchs" => 9, 
			        "num_of_qubits" => 6478, 
			        "num_of_qubits_total" => 10000, 
			        "patch_growth_rate" => array(20,100), 
			        "patch_value" => 5000
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