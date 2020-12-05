<!DOCTYPE html>
<html lang="en-US">
	<head>
		<?php include "includes/head.html"; ?>
		<link rel="stylesheet" href="styles/contact.css">
	</head>
	<body>
		<?php
			if($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["submit"])) {
				$sourceEmail = "litvin.ariela@lmghs.org";
				$emailSubject = "";
				$emailBody = "<div>";
				$name = "";
				if(isset($_POST["name"])) {
					$name = filter_var($_POST["name"], FILTER_SANITIZE_STRING);
					$emailSubject .= $name.":";
					$emailBody .= "<div><p>Name: ".$name."</p></div>";
				}
				$email = "";
				if(isset($_POST["email"])) {
					$email = str_replace(array("\r", "\n", "%0a", "%0d"), "", $_POST["email"]);
					$email = filter_var($email, FILTER_VALIDATE_EMAIL);
					$emailBody .= "<div><p>Email: ".$email."</p></div>";
				}
				$type = "";
				if(isset($_POST["type"])) {
					$type = ucfirst(filter_var($_POST["type"], FILTER_SANITIZE_STRING));
					$emailSubject .= " ".$type;
					$emailBody .= "<div><p>Type: ".$type."</p></div>";
				}
				$message = "";
				if(isset($_POST["message"])) {
					$message = filter_var($_POST["message"], FILTER_SANITIZE_STRING);
					$emailBody .= "<div><p>Message: ".$message."</p></div>";
				}
				$emailBody .= "</div>";
				$recipient = $sourceEmail;
				$headers = "MIME-Version: 1.0\r\nContent-type: text/html; charset=utf-8\r\nFrom: ".$email."\r\n";
				if(mail($recipient, $emailSubject, $emailBody, $headers)) {
					$recipient = $email;
					$emailSubject = "Your email was recieved.";
					$emailBody = "<div><p>Thank you for contacting us, ".$name.". You will get a reply as soon as possible.</p></div>";
					$headers = "MIME-Version: 1.0\r\nContent-type: text/html; charset=utf-8\r\nFrom: ".$sourceEmail."\r\n";
					mail($recipient, $emailSubject, $emailBody, $headers);
				} else {
					$error = "There was an error. Your email must likely did not go through.";
				}
			}
		?>
		<?php include "includes/navbar.php"; ?>
		<!--main contact form-->
		<form class="container-fluid contactForm" method="POST" action="<?php $_SERVER['PHP_SELF']; ?>">
			<h2>Contact</h2>
			<div class="input filled">
				<label for="type">Reason for Message</label>
				<select name="type" id="type" required>
					<option value="feature" <?php if($_GET["type"] == "feature") { echo "selected"; } ?>>Request a Feature</option>
					<option value="bug" <?php if($_GET["type"] == "bug") { echo "selected"; } ?>>Report a Bug</option>
					<option value="press" <?php if($_GET["type"] == "press") { echo "selected"; } ?>>Press</option></option>
					<option value="other <?php if($_GET["type"] == "other") { echo "selected"; } ?>">Other</option>
				</select>
			</div>
			<div class="input">
				<label for="name">Your Name</label>
				<input type="text" name="name" id="name" pattern="[A-Z\sa-z]{2,35}" required />
			</div>
			<div class="input">
				<label for="email">Your Email</label>
				<input type="email" name="email" id="email" required />
			</div>
			<div class="input">
				<label for="message">Message</label>
				<textarea name="message" id="message" required></textarea>
			</div>
			<button type="submit" name="submit" class="btn-dark shineBtn">
				<span class="shine">Send</span>
			</button>
			<p class="errorText"><?php if(isset($error)) { echo $error; } ?></p>
		</form>
		<!--JavaScript/JQuery for contact form-->
		<script>
			//if user typed something, placeholder text remains label
			//otherwise, label returns to placeholder text
			$("form input, form textarea, form select").on(
				"blur",
				function() {
					let $input = $(this).closest(".input");
					if(this.value && this.value != "") {
						$input.addClass("filled");
					} else {
						$input.removeClass("filled");
					}
				}
			);
			//moves placeholder text to label
			$("form input, form textarea, form select").on(
				"focus",
				function() {
					let $input = $(this).closest(".input");
					$input.addClass("filled");
				}
			);
			//resizes textarea to needed height when typing
			$("form textarea").on(
				"input",
				function() {
					this.style.height = "5px";
					this.style.height = (this.scrollHeight + 1) + "px";
				}
			);
		</script>
		<?php include "includes/footer.php" ?>
	</body>
</html>
