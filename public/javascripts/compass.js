$(document).ready(function() {
	alert("");
	//When you click on a link with class of poplight and the href starts with a # 
	$('#openCompass').click(function() {
		  // <!-- For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. --> 
		alert("");

           var swfVersionStr = "10.0.45";
           // <!-- To use express install, set to playerProductInstall.swf, otherwise the empty string. -->
           var xiSwfUrlStr = "playerProductInstall.swf";

           var flashvars = {
				uid: <%= current_user.id %>,
				pid: <%= current_user.current_path %>
			};
           var params = {};
           params.quality = "high";
           params.bgcolor = "#ffffff";
           params.allowscriptaccess = "sameDomain";

           params.allowfullscreen = "true";
           var attributes = {};
           attributes.id = "compass";
           attributes.name = "compass";

           attributes.align = "middle";
           swfobject.embedSWF(
               "/flash/dc_compass_thumbnail_large.swf", "flashcontent", 
               "1112", "500", 
               swfVersionStr, xiSwfUrlStr,flashvars, params, attributes);
			// <!-- JavaScript enabled so display the flashContent div in case it is not replaced with a swf object. -->
			swfobject.createCSS("#flashcontent", "display:block;text-align:left;");
			
	
	    //Fade in the Popup and add close button
	    //$('#' + popID).fadeIn().css({ 'width': Number( popWidth ) }).prepend('<a href="#" class="close"><img src="/images/close_pop.png" class="btn_close" title="Close Window" alt="Close" /></a>');
		$('#flashcontent').fadeIn().css({ 'width': Number( popWidth ) }).append('<a href="#" class="closebutton"><span>Close</span></a>');

	    //Define margin for center alignment (vertical   horizontal) - we add 80px to the height/width to accomodate for the padding  and border width defined in the css
	    var popMargTop = ($('#flashcontent' + popID).height() + 80) / 2;
	    var popMargLeft = ($('#flashcontent' + popID).width() + 80) / 2;

	    //Apply Margin to Popup
	    $('#flashcontent').css({
	        'margin-top' : -popMargTop,
	        'margin-left' : -popMargLeft
	    });

	    //Fade in Background
	    $('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
	    $('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(); //Fade in the fade layer - .css({'filter' : 'alpha(opacity=80)'}) is used to fix the IE Bug on fading transparencies 

	    return false;
	});

	//Close Popups and Fade Layer
	$('a.closebutton, #fade').live('click', function() { //When clicking on the close or fade layer...
	    $('#fade , .course_detail').fadeOut(function() {
	        $('#fade, a.closebutton').remove();  //fade them both out
	    });
	    return false;
	});
});
