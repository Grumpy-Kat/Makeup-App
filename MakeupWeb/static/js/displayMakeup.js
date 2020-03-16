function openTab(tabLink, tabName) {
	$('.tab').css('display', 'none');
	$('.tabLink').removeClass('active');
	$('#' + tabName).css('display', 'block');
	$('#' + tabLink).addClass('active');
}

function openPopup(elem, color, finish) {
	let x = elem.getBoundingClientRect().bottom + 15;
	let y = (elem.getBoundingClientRect().left - elem.getBoundingClientRect().right) / 2;
	let popup = $('.popup');
	popup.addClass('show');
	popup.css('top', x + 'px');
	popup.css('arrowLeft', y + 'px');
	console.log(popup.css('arrowLeft'));
	$('#popupColor').text('Color: ' + color);
	$('#popupFinish').text('Finish: ' + finish);
}

window.addEventListener ? window.addEventListener('load', function() { openTab('tabLink0', 'tab0'); }, false) : window.attachEvent && window.attachEvent('onload', function() { openTab('tabLink0', 'tab0'); });