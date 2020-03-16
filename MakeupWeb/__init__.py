import numpy as np
from colormath.color_objects import sRGBColor
from PIL import Image
from flask import Flask, render_template, request, redirect, url_for
from werkzeug.utils import secure_filename
import os
import colorProcessing

ALLOWED_EXTENSIONS = { 'png', 'jpg', 'jpeg' }

app = Flask(__name__)



@app.route('/', methods = ['GET', 'POST'])
def index():
	if request.method == 'POST':
		if 'file' not in request.files:
			return redirect(request.url)
		file = request.files['file']
		if file.filename == '':
			return redirect(request.url)
		if file and '.' in file.filename and file.filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS:
			filename = secure_filename(file.filename)
			return redirect(url_for('editFile', filename = 'imgs/' + filename))
	return render_template('index.html')

@app.route('/editFile/', methods = ['GET', 'POST'])
def editFile():
	if request.method == 'GET':
		filename = request.args.get('filename')
		return render_template('editFile.html', filename = filename)
	if request.method == 'POST':
		imgSrc = request.form['imgSrc']
		borders = [int(request.form['border-top']) + 15, int(request.form['border-left']) + 10, int(request.form['border-btm']) + 15, int(request.form['border-right'])]
		padding = [int(request.form['padding-horizontal']), int(request.form['padding-vertical'])]
		boxes = [int(request.form['boxes-cols']), int(request.form['boxes-rows'])]
		info = getInfo(imgSrc, borders, padding, boxes)
		save(info)
		return redirect(url_for('displayMakeup'))
	return redirect(url_for('index'))

def getInfo(imgSrc, borders, padding, boxes):
	img, _,  imgWidth, imgHeight = colorProcessing.loadImg(url_for('static', filename = imgSrc)[1:]);
	colors = []
	finishes = []
	width = imgWidth - (borders[1] + borders[3])
	boxWidth = width / boxes[0]
	height = imgHeight - (borders[0] + borders[2])
	boxHeight = height / boxes[1]
	for i in range(0, boxes[0]):
		for j in range(0, boxes[1]):
			top = borders[0] + (boxHeight * j) + padding[1]
			left = borders[1] + (boxWidth * i) + padding[0]
			btm = borders[0] + (boxHeight * (j + 1)) - padding[1]
			right = borders[1] + (boxWidth * (i + 1)) - padding[0]
			cropped = np.array(img.crop((left, top, right, btm)))
			colors.append(colorProcessing.avgColor(cropped).get_value_tuple())
			finishes.append(colorProcessing.getFinish(cropped))
	palettes = ['paletteName'] * len(finishes)
	return [colors, finishes, palettes]
	
def save(info):
	file = open(r'save.txt', 'w')
	for i in range(0, len(info[0])):
		file.write(str(info[0][i][0]) + ',' + str(info[0][i][1]) + ',' + str(info[0][i][2]) + ',' + info[1][i] + ',' + info[2][i] + '\n')
	file.close()

def load():
	file = open(r'save.txt', 'r')
	lines = file.readlines()
	for line in lines:
		line.rstrip()
	return lines

@app.route('/displayMakeup/', methods = ['GET', 'POST'])
def displayMakeup():
	info = load()
	colors = []
	finishes = []
	for i in info:
		color = i.split(',')
		colors.append(sRGBColor(float(color[0]), float(color[1]), float(color[2]), False))
		finishes.append(color[3])
	combined = zip(colors, finishes)
	combined = [(x, y) for x, y in sorted(combined, key = lambda x : colorProcessing.stepSort(x[0], 8))]
	colors, finishes = zip(*combined)
	makeupTuple = []
	for i in range(0, len(colors)):
		item = list(colors[i].get_value_tuple())
		item.append(finishes[i])
		item.append(colorProcessing.getColorName(colors[i]))
		makeupTuple.append(item)
	return render_template('displayMakeup.html', makeup = makeupTuple)
	
@app.errorhandler(404)
def pageNotFound(err):
	return render_template('404.html', err = err)



if __name__ == '__main__':
	app.run()