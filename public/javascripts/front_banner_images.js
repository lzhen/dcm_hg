var bannerImages = function() {
	var img1 = {
		'image': '/images/banner-images/image1.png',
		'hover': '/images/banner-images/image1-large.png',
		'image_w' : 140,
		'image_h' : 192,
		'hover_w' : 240,
		'hover_h' : 241
	};
	var img2 = {
		'image': '/images/banner-images/image2.png',
		'hover': '/images/banner-images/image2-large.png',
		'image_w' : 220,
		'image_h' : 127,
		'hover_w' : 240,
		'hover_h' : 241
	};
	var img3 = {
		'image': '/images/banner-images/image3.png',
		'hover': '/images/banner-images/image3-large.png',
		'image_w' : 220,
		'image_h' : 192,
		'hover_w' : 241,
		'hover_h' : 241
	};
	var img4 = {
		'image': '/images/banner-images/image4.png',
		'hover': '/images/banner-images/image4-large.png',
		'image_w' : 220,
		'image_h' : 127,
		'hover_w' : 241,
		'hover_h' : 241
	};
	var img5 = {
		'image': '/images/banner-images/image5.png',
		'hover': '/images/banner-images/image5-large.png',
		'image_w' : 291,
		'image_h' : 127,
		'hover_w' : 241,
		'hover_h' : 241
	};
	var banner_images = {};
	banner_images['img1'] = img1;
	banner_images['img2'] = img2;
	banner_images['img3'] = img3;
	banner_images['img4'] = img4;
	banner_images['img5'] = img5;
	return banner_images;
}

var fadeInAfterLoad = function(img) {
        var randomDelay = 100 + Math.ceil(Math.random()*2000);
        $(img).delay(randomDelay).fadeIn(1000);
}

$(window).load(function() {
        fadeInAfterLoad('#img1');
        fadeInAfterLoad('#img2');
        fadeInAfterLoad('#img3');
        fadeInAfterLoad('#img4');
        fadeInAfterLoad('#img5');

});



var fadeInAfterLoad000 = function(img) {
	//console.log("-> image %s", img);
	//$(img).click( function() {
		//alert('Handler for image ' + $(this).attr('id') );
	//});
	$(img).hide().bind('load', function() { 
		var randomDelay = 1 + Math.ceil(Math.random()*2000);
		$(this).delay(randomDelay).fadeIn(1000);
	});
}

$(document).ready(function() {
	
	
	//var zindex;
	//var shortUrl;
	//var longUrl;
	//$("ul.banner-images li img").hover(
	//	function() {
	//		
	//	},
	//	function() {
	//		
	//	}
	//);
});


