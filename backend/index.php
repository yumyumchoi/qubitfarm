<html>
<head>
<title>Qubit Farm // API Test</title>
<link rel="shortcut icon" href="img/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="css/qubitfarm.css">
<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="js/qubitfarm.js"></script>
</head>
<body>
	<b>Qubit Farm // API Test</b><br />
	<a href="https://docs.google.com/document/d/1y_P1kZ3rgEq7DFgQj47zNZ1PhBfESD0lGNiyHEqMx0k/edit" target="_blank">API Calls</a><br />
	<textarea id="post">{
    "header": {
        "method": "leaderboard",
        "world_index": 1
    },
    "body": {
        "uid": "qfu1a736aa69d5a0e4f2df9e30cd9ac8d795",
        "num_of_leaders": 10,
        "sort_order": "most to least"
    }
}</textarea>
	<div id="button">Submit</div>
	<div id="posted"></div>
	<div id="returned"></div>
</body>
</html>