<?php

$connection = new MongoClient();
$collection = $connection->qubitfarm->world1;

var_dump($collection);
?>