$(document).ready(function(){
	$('.toggle_div').hide();
	
	$('.toggle_button').hover(function(){
		$(this).css('background','#222');
		$(this).css('border','2px solid #666');
		
	},
	function(){
		$(this).css('background','#111');
		$(this).css('border','2px solid #333');
	});
	
	$('.toggle_button').click(function(){
		$('.toggle_div').slideToggle('normal');
	});

});