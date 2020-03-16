function updateBorderTable() {
	updateBorders();
	updateBoxes();
	updatePadding();
}

function updateBorders() {
	let top = parseInt($('#border-top').val());
	let left = parseInt($('#border-left').val());
	let btm = parseInt($('#border-btm').val());
	let right = parseInt($('#border-right').val());
	let img = $('#img');
	let imgWidth = parseInt(img.width());
	let imgHeight = parseInt(img.height());
	let border = $('#borderTable');
	let borderDiv = $('#borders');
	border.css('width', (imgWidth - (left + right)) + 'px');
	border.css('height', (imgHeight - (top + btm)) + 'px');
	borderDiv.css('left', (left - imgWidth) + 'px');
	borderDiv.css('top', (-btm) + 'px');
}

function updateBoxes() {
	let cols = parseInt($('#boxes-cols').val());
	let rows = parseInt($('#boxes-rows').val());
	let border = $('#borderTable');
	border.empty();
	for(let j = 0; j < rows; j++) {
		row = document.createElement('tr');
		border.append(row);
		for(let i = 0; i < cols; i++) {
			row.append(document.createElement('td'));
		}
	}
}

function updatePadding() {
	let horizontal = parseInt($('#padding-horizontal').val());
	let vertical = parseInt($('#padding-vertical').val());
	$('#borderTable').css('border-spacing', horizontal + 'px ' + vertical + 'px');
}

window.addEventListener ? window.addEventListener('load', updateBorderTable, false) : window.attachEvent && window.attachEvent('onload', updateBorderTable);