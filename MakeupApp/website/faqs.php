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
					"FAQs Question 0" => "FAQs Answer 0",
					"FAQs Question 1" => "FAQs Answer 1",
					"FAQs Question 2" => "FAQs Answer 2",
					"FAQs Question 3" => "FAQs Answer 3",
					"FAQs Question 4" => "FAQs Answer 4",
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
