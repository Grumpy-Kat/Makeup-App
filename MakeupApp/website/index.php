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
					<h1>With GlamKit, planning your makeup looks has never been easier!</h1>
					<h2>Add the palettes in your collection, scroll through all the colors you own, and create breathtaking looks.</h2>
				</div>
				<div class="container row buttons">
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
			<div class="col-md-8 col-md-push-4">
				<div class="text">
					<h2>See all your eyeshadow in one place.</h2>
					<h3>No more searching through endless palettes for that perfect shade.</h3>
				</div>
			</div>
			<div class="col-md-4 col-md-pull-8 phones">
				<div class="container-fluid row">
					<div class="col-xs-6 phone backPhone">
						<div></div>
					</div>
					<div class="col-xs-6 phone frontPhone">
						<div></div>
					</div>
				</div>
			</div>
		</div>
		<!--third section on Saved Looks screen-->
		<div class="container-fluid row screenSection screenSection-rightArrow savedLooks">
			<div class="col-md-8">
				<div class="text">
					<h2>Create looks and save them for another day.</h2>
					<h3>It makes recreating your favorite looks so easy.</h3>
				</div>
			</div>
			<div class="col-md-4 phones">
				<div class="container-fluid row">
					<div class="col-xs-6 phone backPhone">
						<div></div>
					</div>
					<div class="col-xs-6 phone frontPhone">
						<div></div>
					</div>
				</div>
			</div>
		</div>
		<!--fourth section on ColorPicker screen-->
		<div class="container-fluid row screenSection screenSection-leftArrow colorWheel">
			<div class="col-md-8 col-md-push-4">
				<div class="text">
					<h2>Find your precise color using a color wheel.</h2>
					<h3>Perfect if you're copying a face chart or have a dream color in mind.</h3>
				</div>
			</div>
			<div class="col-md-4 col-md-pull-8 phones">
				<div class="container-fluid row">
					<div class="col-xs-6 phone backPhone">
						<div></div>
					</div>
					<div class="col-xs-6 phone frontPhone">
						<div></div>
					</div>
				</div>
			</div>
		</div>
		<!--fifth section on Palette Divider screen-->
		<div class="container-fluid row screenSection screenSection-rightArrow paletteDivider">
			<div class="col-md-8">
				<div class="text">
					<h2>Compare other palettes to your collection.</h2>
					<h3>Useful for comparing to other palettes while shopping or finding dupes when recreating a look.</h3>
				</div>
			</div>
			<div class="col-md-4 phones">	
				<div class="container-fluid row">
					<div class="col-xs-6 phone backPhone">
						<div></div>
					</div>
					<div class="col-xs-6 phone frontPhone">
						<div></div>
					</div>
				</div>
			</div>
		</div>
		<!--sixth section on Swatch screen-->
		<div class="container-fluid row screenSection screenSection-leftArrow editSwatch">
			<div class="col-md-8 col-md-push-4">
				<div class="text">
					<h2>Find your precise color using a color wheel.</h2>
					<h3>Perfect if you're copying a face chart or have a dream color in mind.</h3>
				</div>
			</div>
			<div class="col-md-4 col-md-pull-8 phones">
				<div class="container-fluid row">
					<div class="col-xs-6 phone backPhone">
						<div></div>
					</div>
					<div class="col-xs-6 phone frontPhone">
						<div></div>
					</div>
				</div>
			</div>
		</div>
		<?php include "includes/footer.php" ?>
	</body>
</html>
