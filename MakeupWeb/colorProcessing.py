import numpy as np
from colormath.color_objects import sRGBColor, HSVColor, LabColor
from colormath.color_conversions import convert_color
from colormath.color_diff import delta_e_cie2000
from PIL import Image
import tensorflow as tf
import cv2
import math
import os
import sys

model = tf.keras.models.load_model('training/finishes-0.001-5-50-2conv.h5')
	
def stepSort(rgb, step = 1):
	r, g, b = rgb.get_value_tuple()
	threshold = 0.085
	isGray = abs(r - g) < threshold and abs(r - b) < threshold and abs(g - b) < threshold
	h, s, v = convert_color(rgb, HSVColor).get_value_tuple()
	lum = math.sqrt(0.241 * r + 0.691 * g + 0.068 * b)
	h2 = int(h * step)
	lum2 = int(lum * step)
	v2 = int(v * step)
	if isGray:
		return (0, lum2, v2)
	return(1, h2, lum2, v2)

def createColorWheel():
	colorWheel = {}
	colorWheel['white'] = sRGBColor(1, 1, 1, False)
	colorWheel['gray'] = sRGBColor(0.5, 0.5, 0.5, False)
	colorWheel['black'] = sRGBColor(0, 0, 0, False)
	colorWheel['light red'] = sRGBColor(1, 0.8, 0.8, False)
	colorWheel['red'] = sRGBColor(1, 0, 0, False)
	colorWheel['dark red'] = sRGBColor(0.2, 0, 0, False)
	colorWheel['light orange'] = sRGBColor(1, 0.9, 0.8, False)
	colorWheel['orange'] = sRGBColor(1, 0.5, 0, False)
	colorWheel['dark orange'] = sRGBColor(0.2, 0.1, 0, False)
	colorWheel['light yellow'] = sRGBColor(1, 1, 0.8, False)
	colorWheel['yellow'] = sRGBColor(1, 1, 0, False)
	colorWheel['dark yellow'] = sRGBColor(0.2, 0.2, 0, False)
	colorWheel['light chartreuse'] = sRGBColor(0.9, 1, 0.8, False)
	colorWheel['chartreuse'] = sRGBColor(0.5, 1, 0, False)
	colorWheel['dark chartreuse'] = sRGBColor(0.1, 0.2, 0, False)
	colorWheel['light green'] = sRGBColor(0.8, 1, 0.8, False)
	colorWheel['green'] = sRGBColor(0, 1, 0, False)
	colorWheel['dark green'] = sRGBColor(0, 0.2, 0, False)
	colorWheel['light spring green'] = sRGBColor(0.8, 1, 0.9, False)
	colorWheel['spring green'] = sRGBColor(0, 1, 0.5, False)
	colorWheel['dark spring green'] = sRGBColor(0, 0.2, 0.1, False)
	colorWheel['light aqua'] = sRGBColor(0.8, 1, 1, False)
	colorWheel['aqua'] = sRGBColor(0, 1, 1, False)
	colorWheel['dark aqua'] = sRGBColor(0, 0.2, 0.2, False)
	colorWheel['light dodger blue'] = sRGBColor(0.8, 0.9, 1, False)
	colorWheel['dodger blue'] = sRGBColor(0, 0.5, 1, False)
	colorWheel['dark dodger blue'] = sRGBColor(0, 0.1, 0.2, False)
	colorWheel['light blue'] = sRGBColor(0.8, 0.8, 1, False)
	colorWheel['blue'] = sRGBColor(0, 1, 1, False)
	colorWheel['dark blue'] = sRGBColor(0, 0, 0.2, False)
	colorWheel['light indigo'] = sRGBColor(0.9, 0.8, 1, False)
	colorWheel['indigo'] = sRGBColor(0.5, 0, 1, False)
	colorWheel['dark indigo'] = sRGBColor(0.1, 0, 0.2, False)
	colorWheel['light purple'] = sRGBColor(1, 0.8, 1, False)
	colorWheel['purple'] = sRGBColor(1, 0, 1, False)
	colorWheel['dark purple'] = sRGBColor(0.2, 0, 0.2, False)
	colorWheel['light violet'] = sRGBColor(1, 0.8, 0.9, False)
	colorWheel['violet'] = sRGBColor(1, 0, 0.5, False)
	colorWheel['dark violet'] = sRGBColor(0.2, 0, 0.1, False)
	return colorWheel
	
def colorSort(rgb):
	r, g, b = rgb.get_value_tuple()
	color0 = convert_color(rgb, LabColor)
	threshold = 0.085
	isGray = abs(r - g) < threshold and abs(r - b) < threshold and abs(g - b) < threshold
	if isGray:
		color1 = convert_color(sRGBColor(0, 0, 0, False), LabColor)
		return (0, delta_e_cie2000(color0, color1))
	color1 = convert_color(sRGBColor(1, 0, 0, False), LabColor)
	return (1, delta_e_cie2000(color0, color1))
	
def loadImg(path):
	img = Image.open(path.replace('/', '\\'), 'r').convert('RGB')
	width, height = img.size;
	pxs = list(img.getdata())
	return (img, np.array(pxs).reshape((width, height, 3)), width, height)
	
def avgColor(img):
	totalColor = [0, 0, 0]
	for x in range(0, img.shape[0]):
		for y in range(0, img.shape[1]):
			totalColor[0] += img[x][y][0]
			totalColor[1] += img[x][y][1]
			totalColor[2] += img[x][y][2]
	size = (img.shape[0] * img.shape[1])
	return sRGBColor(totalColor[0] / size / 255, totalColor[1] / size / 255, totalColor[2] / size / 255, False)

def maxColor(img):
	colors = []
	numOccurences = []
	for x in range(0, img.shape[0]):
		for y in range(0, img.shape[1]):
			for i in range(0, len(colors)):
				if(colors[i][0] == img[x][y][0] and colors[i][1] == img[x][y][1] and colors[i][2] == img[x][y][2]):
					numOccurences[i] += 1
					break
			else:
				colors.append(img[x][y])
				numOccurences.append(1)
	color = colors[numOccurences.index(max(numOccurences))]
	return sRGBColor(color[0] / 255, color[1] / 255, color[2] / 255, False)

def getFinish(img):
	newImg = cv2.resize(cv2.cvtColor(img, cv2.COLOR_RGB2GRAY), (32, 32)) / 255.0
	newImg = newImg.reshape(-1, 32, 32, 1)
	prediction = np.argmax(model.predict(newImg))
	if(prediction == 0):
		return 'matte'
	elif(prediction == 1):
		return 'satin'
	elif(prediction == 2):
		return 'shimmer'
	elif(prediction == 3):
		return 'metallic'
	elif(prediction == 4):
		return 'glitter'
	else:
		return 'other'
	
def getColorName(rgb):
	minDist = sys.maxsize
	minColor = 'unknown'
	color0 = convert_color(rgb, LabColor)
	for color in colorWheel:
		color1 = convert_color(colorWheel[color], LabColor)
		dist = delta_e_cie2000(color0, color1)
		if(dist < minDist):
			minDist = dist
			minColor = color
	return minColor

def removeBackground(img):
	cv2Img = cv2.cvtColor(cv2.UMat(np.array(img)), cv2.COLOR_RGB2BGR)
	dim = cv2Img.shape
	mask = cv2.cvtColor(cv2Img, cv2.COLOR_BGR2GRAY)
	mask = cv2.GaussianBlur(mask, (5, 5), cv2.BORDER_DEFAULT)
	_, mask = cv2.threshold(mask, 250, 255, cv2.THRESH_TOZERO_INV)
	contours = cv2.findContours(cv2.UMat(mask), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)[-2]
	contours = sorted(contours, key = cv2.contourArea)
	mask = np.zeros(cv2Img.shape[:2], np.uint8)
	cv2.drawContours(mask, contours, -1, 255, -1)
	newImg = cv2.bitwise_and(cv2Img, cv2Img, mask = mask)
	cv2.floodFill(newImg, None, (0, 0), (255, 255, 255), (8.5, ) * 3, (8.5, ) * 3)
	cv2.floodFill(newImg, None, (dim[1] - 1, 0), (255, 255, 255), (8.5, ) * 3, (8.5, ) * 3)
	cv2.floodFill(newImg, None, (0, dim[0] -1 ), (255, 255, 255), (8.5, ) * 3, (8.5, ) * 3)
	cv2.floodFill(newImg, None, (dim[1] - 1, dim[0] - 1), (255, 255, 255), (8.5, ) * 3, (8.5, ) * 3)
	return Image.fromarray(cv2.cvtColor(newImg, cv2.COLOR_BGR2RGB))

colorWheel = createColorWheel();