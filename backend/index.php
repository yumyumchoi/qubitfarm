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
		<a id="0" href="javascript:setAPIcall('create_user.json',0);">create user</a>, 
		<a id="1" href="javascript:setAPIcall('leaderboard.json',1);">leaderboard</a>, 
		<a id="2" href="javascript:setAPIcall('get_plots.json',2);">get plots</a>, 
		<a id="3" href="javascript:setAPIcall('get_user.json',3);">get user</a>, 
		<a id="4" href="javascript:setAPIcall('create_world.json',4);">create world</a>, 
		<a id="5" href="javascript:iFrame('1y_P1kZ3rgEq7DFgQj47zNZ1PhBfESD0lGNiyHEqMx0k');">Google Doc</a>
		<div id="button">Submit</div>
	</div>
	<textarea id="post"></textarea>
	<div id="posted"></div>
	<div id="returned"></div>
</div>
</body>
</html>