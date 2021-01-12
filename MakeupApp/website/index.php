<!DOCTYPE html>
<html lang="en-US">
	<head>
		<?php include "includes/head.html"; ?>
		<link rel="stylesheet" href="styles/headerSection.css">
		<link rel="stylesheet" href="styles/screenSections.css">
	</head>
	<body>
		<?php include "includes/navbar.php" ?>
		<!--first section-->
		<div class="container-fluid row headerSection">
			<div class="col-md-6">
				<div class="text">
					<h1>Planning your makeup has never been easier!</h1>
					<h2>Add the palettes in your collection, scroll through all your shades, and create breathtaking looks.</h2>
				</div>
				<div class="container row buttons headerButtons">
					<button type="button" class="col-xs-6 btn btn-dark shineBtn iOS">
						<div class="shine"></div>
					</button>
					<button type="button" class="col-xs-6 btn btn-dark shineBtn android">
						<span class="shine"></span>
					</button>
				</div>
			</div>
			<div class="col-md-6">
				<div class="phone"></div>
			</div>
		</div>
		<!--second section on All Swatches screen-->
		<div class="container-fluid row screenSection screenSection-leftArrow allSwatches">
			<div class="col-md-8 col-md-push-4 textParent">
				<div class="text">
					<h2>See all your eyeshadows in one place.</h2>
					<div class="minimized textSubsection active">
						<h3>No more searching through endless palettes for that perfect shade.</h3>
						<h3><a class="toggle">Show more...</a></h3>
					</div>
					<div class="expanded textSubsection">
						<ul>
							<li>Easily import a picture of your eyeshadow palettes and divide up the shades. GlamKit will do the rest for you, finding the color and finish of each shade.</li>
							<li>Then, you can see all your eyeshadows in one scrollable list. You no longer have to open all your palettes as you create your look. It's like shopping your own collection.</li>
							<li>Scrolling through the list is also a great way to get inspiration directly from your collection. It helps you get more creative with your looks.</li>
							<li>Sort the shades however you want, such as by color, finish, or palette. You can also sort by your favorite shades, darkest shades, or lightest shades. It's makes it much easier to find the perfect shade you're looking for.</li>
							<li>No more forgetting shades or using the same few palettes when you have so many palettes gathering dust. You might just find your new favorite shade.</li>
						</ul>
						<p><a class="toggle">Show less...</a></p>
					</div>
				</div>
			</div>
			<div class="col-md-4 col-md-pull-8 phone">
				<div>
					<video id="scrollingVideo" tabindex="0" autobuffer preload>
						<source src="imgs/screenshots/dark AllSwatches video.mp4" type="video/mp4" />
					</video>
					<script>
						var video = $("#scrollingVideo")[0];
						var orgVideoTop;
						
						video.addEventListener(
							'loadedmetadata',
							function() {
								orgVideoTop = $(video).offset().top;
							}
						);
						
						function scrollPlay() {
							let frame = getFrame();
							if(isNaN(frame)) {
								console.log(frame);
								frame = 0;
							}
							video.currentTime = frame;
							window.requestAnimationFrame(scrollPlay);
						}
						
						function getFrame() {
							let heightMultiplier = 0.87;
							let screenHeight = window.screen.height;
							let videoTop = video.getBoundingClientRect().top;
							if((screenHeight - videoTop) < -screenHeight * 0.5) {
								return 0;
							}
							if(videoTop < -screenHeight * 0.5) {
								return video.duration;
							}
							let maxHeight = screenHeight * 2;
							if(orgVideoTop < screenHeight) {
								//video starts on screen already, needs to be accounted for
								maxHeight = screenHeight + orgVideoTop;
							}
							let playbackMultiplier = video.duration / (maxHeight * heightMultiplier);
							videoTop -= maxHeight * ((1 - heightMultiplier) / 2);
							return lerp(maxHeight * ((1 - heightMultiplier) / 2), maxHeight * heightMultiplier, (videoTop + screenHeight)) * playbackMultiplier;
						}
						
						function lerp(a, b, f) {
							return (b - f + a) / (b - a) * b;
						}
						
						$(document).ready(
							function() {
								window.requestAnimationFrame(scrollPlay);
							}
						);
					</script>
				</div>
			</div>
		</div>
		<!--third section on Saved Looks screen-->
		<div class="container-fluid row screenSection screenSection-rightArrow savedLooks">
			<div class="col-md-8 textParent">
				<div class="text">
					<h2>Create looks and save them for another day.</h2>
					<div class="minimized textSubsection active">
						<h3>It makes recreating your favorite looks so easy.</h3>
						<h3><a class="toggle">Show more...</a></h3>
					</div>
					<div class="expanded textSubsection">
						<ul>
							<li>Simply double click on any shade you want to add to Today's Look. You can also save that stunning look to recreate another day.</li>
							<li>You can name your looks to make them easier to remember and recreate.</li>
							<li>Doing your makeup will be quicker because you've already saved plenty of looks.</li>
							<li>You can now plan your makeup anytime, even when you're not home.</li>
							<li>It makes packing your travel bag faster and travelling easier. You no longer have to worry about leaving an important palette at home.</li>
						</ul>
						<p><a class="toggle">Show less...</a></p>
					</div>
				</div>
			</div>
			<div class="col-md-4 phone">
				<div></div>
			</div>
		</div>
		<!--fourth section on ColorPicker screen-->
		<div class="container-fluid row screenSection screenSection-leftArrow colorWheel">
			<div class="col-md-4 phone">
				<div></div>
			</div>
			<div class="col-md-8 textParent">
				<div class="text">
					<h2>Find your precise color using a color wheel.</h2>
					<div class="minimized textSubsection active">
						<h3>Perfect if you're copying a face chart or have a dream color in mind.</h3>
						<h3><a class="toggle">Show more...</a></h3>
					</div>
					<div class="expanded textSubsection">
						<ul>
							<li>Have you ever had a very specific shade in mind for a look? Or maybe you're copying an inspiration?</li>
							<li>Instead of searching through endless palettes, simply find the color on the color wheel. Then, you'll see all the closest shades in your collection.</p>
						</ul>
						<p><a class="toggle">Show less...</a></p>
					</div>
				</div>
			</div>
		</div>
		<!--fifth section on Palette Divider screen-->
		<div class="container-fluid row screenSection screenSection-rightArrow paletteDivider">
			<div class="col-md-4 phone">
				<div></div>
			</div>
			<div class="col-md-8 textParent">
				<div class="text">
					<h2>Compare other palettes to your collection.</h2>
					<div class="minimized textSubsection active">
						<h3>Useful for comparing to other palettes while shopping or finding dupes when recreating a look.</h3>
						<h3><a class="toggle">Show more...</a></h3>
					</div>
					<div class="expanded textSubsection">
						<ul>
							<li>If you're shopping, you can just upload a picture of a palette you're considering. GlamKit will show you all the similar shades in your collection. It's a great way to save some money and avoid buying an almost identical shade for the hundredth time.</li>
							<li>If you're trying to recreate a look that you saw on Instagram or Youtube, just upload a picture of a palette that the original artist used. You can easily find dupes in your collection. It saves you time because you no longer have to spend time comparing swatches or Googling dupes that you might not even own.</li>
						</ul>
						<p><a class="toggle">Show less...</a></p>
					</div>
				</div>
			</div>
		</div>
		<!--sixth section on Swatch screen-->
		<div class="container-fluid row screenSection screenSection-leftArrow editSwatch">
			<div class="col-md-8 col-md-push-4 textParent">
				<div class="text">
					<h2>Customize details about each shade.</h2>
					<div class="minimized textSubsection active">
						<h3>Add details, such as price, weight, rating, tags, and more, to make it easier to remember which shades you love to use.</h3>
						<h3><a class="toggle">Show more...</a></h3>
					</div>
					<div class="expanded textSubsection">
						<ul>
							<li>Clicking on any shade will give you basic information about it, such as color, finish, palette, brand, and shade name. There you can click on the "More..." button to get all the information about it.</li>
							<li>You can edit the basic information. You can also add more details, such as price, weight, tags, and rating. This makes it easier to remember how a shade performs, which shades you love, and find the perfect shade for your look.</li>
						</ul>
						<p><a class="toggle">Show less...</a></p>
					</div>
				</div>
			</div>
			<div class="col-md-4 col-md-pull-8 phone">
				<div></div>
			</div>
		</div>
		<script>
			$(".textSubsection .toggle").on(
				"click",
				function(e) {
					let $textSubsection = $(this).closest(".textSubsection.active");
					let $otherTextSubsection = $textSubsection.siblings(".textSubsection:not(.active)");
					$textSubsection.hide(400);
					$textSubsection.removeClass("active");
					$otherTextSubsection.show(600);
					$otherTextSubsection.addClass("active");
				}
			);
		</script>
		<?php include "includes/footer.php" ?>
	</body>
</html>
