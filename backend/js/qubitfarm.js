// ---------------------------------------------------------------------------------------------------- //\

$(document).ready( function() {
	buttonHandler();
	textAreaTab();
	setAPIcall('leaderboard.json',1);
});

// ---------------------------------------------------------------------------------------------------- //\

function getData(thePost) {
	$.ajax({
		url: "api/",
		type: 'POST',
		dataType: 'json',
		data: thePost,
		success: function(data) {
			$("#returned").css({'background-color':'#E6F5E6'});
			$('#button').css({"opacity":1,"display":"block"});
			$('#returned').animate({"opacity":1},250);
			$('#returned').html('<b>Returned Successfully @ '+new Date()+'</b><pre>'+JSON.stringify(data, undefined, 2)+'</pre>');
		},
		error: function(data) {
			$("#returned").css({'background-color':'#ead1dc'});
			$('#button').css({"opacity":1,"display":"block"});
			$('#returned').animate({"opacity":1},250);
			$('#returned').html('<b>Returned with Errors @ '+new Date()+'</b><pre>'+JSON.stringify(data, undefined, 2)+'</pre>');
		}
	});
}

// ---------------------------------------------------------------------------------------------------- //

function textAreaTab() {
	$("textarea").keydown(function(e) {
	    if(e.keyCode === 9) { // tab was pressed
	        // get caret position/selection
	        var start = this.selectionStart;
	        var end = this.selectionEnd;

	        var $this = $(this);
	        var value = $this.val();

	        // set textarea value to: text before caret + tab + text after caret
	        $this.val(value.substring(0, start)
	                    + "\t"
	                    + value.substring(end));

	        // put caret at right position again (add one for the tab)
	        this.selectionStart = this.selectionEnd = start + 1;

	        // prevent the focus lose
	        e.preventDefault();
	    }
	});
}

// ---------------------------------------------------------------------------------------------------- //

function buttonHandler() {
	$('#button').click( function(){
		$('#button').css({"opacity":0,"display":"none"});
		$('#returned').css({"opacity":1,'background-color':'#EBF5FF'});
		$('#returned').text('Loading...');
		$('#posted').css({"opacity":1});
		var thePost = $('#post').val();
		$('#posted').html('<b>Posted @ '+new Date()+'</b><pre>'+thePost+'</pre>');
		getData(thePost);
	});
	
	var c = 0;
	$('#posted').click( function(){
		c++;
		if (c == 1) {
			$(this).css({"overflow-y":"scroll"});
			$(this).animate({"height":200},250);
			
		}
		if (c == 2) {
			$(this).animate({"height":16},250);
			$(this).css({"overflow":"hidden"});
			c = 0;
		}
	});
}

// ---------------------------------------------------------------------------------------------------- //

function setAPIcall(call,link) {
	for(i=0;i<7;i++) { 
		if (i == link) { 
			$("#"+i).css({"text-decoration":"underline"});
		} else {
			$("#"+i).css({"text-decoration":"none"});
		}
	}
	$.ajax({
		url: "api/json/example_posts/"+call,
		type: 'GET',
		dataType: 'json',
		success: function(data) {
			$("textarea").text(JSON.stringify(data, undefined, 2));
			$("textarea").val(JSON.stringify(data, undefined, 2));
		},
		error: function(data) {
		}
	});
}

// ---------------------------------------------------------------------------------------------------- //

function iFrame(doc_id) {
	$('#main').append(
		'<div id="iframe-box"><iframe src="https://docs.google.com/document/d/'+doc_id+'"></iframe></div>'
	);
	$('#iframe-box').click( function(){
		$(this).remove();
	});
}
