//katello js file for the screenshot carousel (but potentially for other things)
$(document).ready(function(){
	if(!$("#katello-screenshot-carousel").is(":empty")){
		$("#katello-screenshot-carousel").CloudCarousel( { 
			minScale: 0.45,
			reflHeight: 23,
			reflGap:0,
			xRadius: 150,
			yRadius:10,
			xPos: 200,
			yPos: 120,
			speed:0.10,
			mouseWheel: false,
			autoRotate: 'right',
			autoRotateDelay: 5000
		});
		$("#katello-screenshot-carousel").css({"overflow":"visible"}).fadeIn();
	}
});