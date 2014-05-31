// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({  
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});

$(document).ready(function (){ 
	$("#search_form").keyup(function() {
		var form = $(this);
		var url = form.attr("action");
		var formData = form.serialize();
		$.get(url, formData, function(html) { // perform an AJAX get, the trailing function is what happens on successful get.
		    $("#users").html(html); // replace the "results" div with the result of action taken
		});
	});
	
	// $(".search_name").focus();
});
