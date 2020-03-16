function fileChanged(fileChooser) {
	console.log('fileChanged');
	if(fileChooser.files && fileChooser.files[0]) {
			let reader = new FileReader();
			reader.onload = function (e) {
				 $('#img').attr('src', e.target.result).attr('style', 'display: block;');
			};
			reader.readAsDataURL(fileChooser.files[0]);
	 }
}