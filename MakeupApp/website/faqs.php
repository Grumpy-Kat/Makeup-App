<!DOCTYPE html>
<html lang="en-US">
	<head>
		<?php include "includes/head.html"; ?>
		<link rel="stylesheet" href="styles/faqs.css">
	</head>
	<body>
		<?php include "includes/navbar.php" ?>
		<!--main FAQs section-->
		<div class="container-fluid accordion faqsSection">
			<?php
				$faqs = array(
					"What are some planned features for future updates?" => 
					"<p>Planned features include: </p>
					<ul>
						<li>Filtering swatch lists based on color, finish, rating, tags, and more to make it easier to find that perfect shade in your collection.</li>
						<li>Making swatch lists searchable to make it even easier to find the shade you have in mind.</li>
						<li>Adding photos of swatches to each shade, including in different lights, in case the shadows look different than in the pan.</li>
						<li>Adding photos of your looks and dates that you wore a look.</li>
						<li>Adding notes and estimates of the time it will take to do a look, to make it easier to plan your mornings.</li>
						<li>Sharing your looks and collection with friends, so you can show off your gorgeous makeup.</li>
						<li>Improving finish detection.</li>
						<li>Adding features for iridescent, multichrome, and duochrome eyeshadows to support your full collection.</li>
						<li>Face, lips, sfx, and other product sections to help you create a full face look.</li>
					</ul>
					<p>If you have an idea for a feature not listed here, you can <a href=\"contact.php?type=feature\">request it here.</a> Please remember that this app is still in an early phase of development and will have many features added soon.</p>",
					
					"How do I use the app?" =>
					"<p>You should see a tutorial when you open the app for the first time. If you want to see it again, go to the \"Settings\" screen in the app and click on the \"Help\" button.</p>
					<p>Also, many screens have additional instructions, found by clicking the question mark in the upper right corner.</p>
					<p>If you have any other questions, you can <a href=\"contact.php?type=other\">contact us here.</a> We are also working on some other tutorials and features to make the app easier to use.</p>",
					
					"Why do my shade colors come out so weird?" =>
					"<p>It may be a problem with your lighting, but GlamKit has settings to accomodate that. To adjust the colors of the shades, add the palette. When you see the preview of the palette's shade, you will find fields to adjust your brightness, red, green, and blue tones. Type in a positive number to make it brighter or add more of that color. Type in a negative number to have the opposite effect. The palette's swatches will preview the changes you are making. You can also save the changes for all future palettes you might add by going to the \"Settings\" screen and clicking on the \"Photo Upload\" section. You'll find the same fields to edit.</p>",
					
					"Is GlamKit available in other languages?" =>
					"<p>Yes, its available in English and Russian. We're currently working on a few more langauges, such as Spanish.</p>",
					
					"Where is my data stored?" =>
					"Your data is stored on your device. It is completely private to you. We never sell or share our customers' data with advertisers or other third parties.",
					
					"Can I get my GlamKit data onto my new phone?" =>
					"We're currently working on some backup methods, such as iCloud. Hopefully we can get that in an update soon.",
					
					"I have a question that's not on this list." =>
					"<p>You can <a href=\"contact.php?type=other\">contact us here.</a></p>",
				);
				foreach($faqs as $question => $answer) {
					$i = array_search($question, array_keys($faqs));
					echo "<div class='card faqs".$i."'>
						<div class='card-header' id='faqsQuestion".$i."'>
							<button class='btn btn-link collapsed' type='button' data-toggle='collapse' data-target='#faqsAnswer".$i."' aria-expanded='true' aria-controls='faqsAnswer".$i."'>
								<h2>".$question."</h2>
							</button>
						</div>
						<div id='faqsAnswer".$i."' class='collapse' aria-labelledby='faqsQuestion".$i."' data-parent='#faqsSection'>
							<div class='card-body'>".$answer."</div>
						</div>
					</div>";
				}
			?>
		</div>
		<script>
			$(document).ready(
				function(){
					$(".collapse").on(
						'show.bs.collapse',
						function(){
							$(this).prev(".card-header").addClass("active");
						}
					).on(
						'hide.bs.collapse',
						function(){
							$(this).prev(".card-header").removeClass("active");
						}
					);
				}
			);
		</script>
		<?php include "includes/footer.php" ?>
	</body>
</html>
