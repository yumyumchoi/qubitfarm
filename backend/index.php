<?php
	header( 'Expires: Sat, 26 Jul 1997 05:00:00 GMT' ); 
	header( 'Last-Modified: ' . gmdate( 'D, d M Y H:i:s' ) . ' GMT' ); 
	header( 'Cache-Control: no-store, no-cache, must-revalidate' ); 
	header( 'Cache-Control: post-check=0, pre-check=0', false ); 
	header( 'Pragma: no-cache' ); 	
?>
<html>
<head>
<title>Qubit Farm // API Test</title>
<link rel="shortcut icon" href="img/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="css/qubitfarm.css">
<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="js/qubitfarm.js"></script>
</head>
<body>
<div id="main">
	<h1>Qubit Farm // API Test</h1><br />
	<div id="actions">
		<a id="0" href="javascript:setAPIcall('purchase_plot.json',0);">purchase plot</a>, 
		<a id="1" href="javascript:setAPIcall('create_user.json',1);">create user</a>, 
		<a id="2" href="javascript:setAPIcall('leaderboard.json',2);">leaderboard</a>, 
		<a id="3" href="javascript:setAPIcall('get_plots.json',3);">get plots</a>, 
		<a id="4" href="javascript:setAPIcall('get_user.json',4);">get user</a>, 
		<a id="5" href="javascript:setAPIcall('create_world.json',5);">create world</a>, 
		<a id="6" href="javascript:iFrame('1y_P1kZ3rgEq7DFgQj47zNZ1PhBfESD0lGNiyHEqMx0k');">Google Doc</a>
		<div id="button">Submit</div>
	</div>
	<textarea id="post"></textarea>
	<div id="posted"></div>
	<div id="returned"></div>
</div>
</body>
</html>