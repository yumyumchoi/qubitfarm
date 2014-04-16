// ---------------------------------------------------------------------------------------------------- //\

$(document).ready( function() {
	$('#button').click( function(){
		$('#returned').css({"opacity":0});
		$('#posted').css({"opacity":0});
		var thePost = $('#post').val();
		$('#posted').animate({"opacity":1},250);
		$('#posted').html('<b>Post // '+new Date()+'</b><pre>'+thePost+'</pre>');
		getData(thePost);
	});
});

// ---------------------------------------------------------------------------------------------------- //\

function getData(thePost) {
	$.ajax({
		url: "api/",
		type: 'POST',
		dataType: 'json',
		data: thePost,
		success: function(data) {
			$('#returned').animate({"opacity":1},250);
			$('#returned').html('<b>Return (Success) // '+new Date()+'</b><pre>'+JSON.stringify(data, undefined, 2)+'</pre>');
		},
		error: function(data) {
			$('#returned').animate({"opacity":1},250);
			$('#returned').html('<b>Return (Error) // '+new Date()+'</b><pre>'+JSON.stringify(data, undefined, 2)+'</pre>');
		}
	});
}

// ---------------------------------------------------------------------------------------------------- //\
