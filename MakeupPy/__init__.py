import numpy as np
import kivy
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.properties import ObjectProperty
from kivy.clock import Clock
from kivymd.app import MDApp
from kivymd.theming import ThemeManager
from colormath.color_objects import sRGBColor
import swatch
import colorProcessing
import widgets
import time
import threading

kivy.require('1.11.1')



class Main0Screen(Screen):
	scroll = ObjectProperty(None)
	swatchParent = ObjectProperty(None)
	infoBox = ObjectProperty(None)
	currSwatchBar = ObjectProperty(None)
	recommendedSwatchBar = ObjectProperty(None)
	recommendedInfoBox = ObjectProperty(None)
	
	def addSwatches(self):
		self.swatches = loadFormatted()
		if len(self.swatches) > 0:
			for swatch in self.swatches:
				colorTuple = swatch.color.get_value_tuple()
				onInteract = lambda *args, swatch = swatch, swatches = self.swatches, scroll = self.scroll, infoBox = self.infoBox, recommendedSwatchBar = self.recommendedSwatchBar, recommendedInfoBox = self.recommendedInfoBox, currSwatchBar = self.currSwatchBar : onTouch(swatch, swatches, scroll, infoBox, recommendedSwatchBar, recommendedInfoBox, currSwatchBar, args[0], args[1])
				btn = widgets.ImageButton(source = f'imgs/{swatch.finish}.png', color = (colorTuple[0], colorTuple[1], colorTuple[2], 1), keep_ratio = True)
				btn.bind(on_touch_down = onInteract)
				self.swatchParent.add_widget(btn)
		else:
			self.swatchParent.add_widget(Label(text = 'No colors found!', halign = 'center', valign = 'middle', font_size = 30, color = app.theme_cls.primary_color))
		onInteract = lambda *args : app.setScreen('AddPaletteScreen')
		btn = widgets.ImageButton(source = f'imgs/plus.png', color = app.theme_cls.accent_color)
		btn.bind(on_press = onInteract)
		self.swatchParent.add_widget(btn)
		self.swatchParent.bind(minimum_height = self.updateHeight)
		
	def on_pre_enter(self):
		self.infoBox.close()
		self.currSwatchBar.clear()
		for swatch in currSwatches:
			colorTuple = swatch.color.get_value_tuple()
			self.currSwatchBar.addSwatch(colorTuple, swatch.finish)
			
	def onTouch(self, swatch, btn, touch):
		if btn.collide_point(*touch.pos):
			if touch.is_double_tap:
				if not swatch in currSwatches:
					self.infoBox.close()
					self.recommendedInfoBox.close()
					currSwatches.append(swatch)
					colorTuple = swatch.color.get_value_tuple()
					self.currSwatchBar.addSwatch(colorTuple, swatch.finish)
					self.recommendedSwatchBar.addRecommendedSwatches(swatch, self.swatches, self.onTouch)
					self.recommendedSwatchBar.open()
					self.scroll.size_hint_y = 0.7
			else:
				colorName = colorProcessing.getColorName(swatch.color)
				touchPos = btn.to_local(*touch.pos)
				touchPos = btn.to_window(*touchPos)
				if self.recommendedSwatchBar.isOpen and self.recommendedSwatchBar.collide_point(*touchPos):
					#arrow down
					self.recommendedInfoBox.arrowUp = False
					self.recommendedInfoBox.y = btn.top + btn.parent.spacing[1] + btn.parent.parent.y + 5
					self.recommendedInfoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
					self.recommendedInfoBox.open()
				else:
					self.recommendedSwatchBar.close()
					self.scroll.size_hint_y = 0.8
					if(touch.y > self.infoBox.height + self.currSwatchBar.height + self.recommendedSwatchBar.height):
						#arrow up
						self.infoBox.arrowUp = True
						self.infoBox.top = btn.y - btn.parent.spacing[1]
					else:
						#arrow down
						self.infoBox.arrowUp = False
						self.infoBox.y = btn.top + btn.parent.spacing[1]
					self.infoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
					self.infoBox.open()
		elif not touch.is_mouse_scrolling:
			self.infoBox.close()
			self.recommendedInfoBox.close()
			self.recommendedSwatchBar.close()
			self.scroll.size_hint_y = 0.8
		
	def updateHeight(self, *_):
		self.swatchParent.parent.height = self.swatchParent.minimum_height



class Main1Screen(Screen):
	colorPicker = ObjectProperty(None)
	scroll = ObjectProperty(None)
	swatchParent = ObjectProperty(None)
	infoBox = ObjectProperty(None)
	currSwatchBar = ObjectProperty(None)
	recommendedSwatchBar = ObjectProperty(None)
	recommendedInfoBox = ObjectProperty(None)
	
	def addSwatches(self, *_):
		self.swatchParent.clear_widgets()
		self.swatches = loadFormatted()
		self.swatches = colorProcessing.getSimilarColors(
			rgb = sRGBColor(self.colorPicker.color[0], self.colorPicker.color[1], self.colorPicker.color[2], False),
			swatches = self.swatches,
			maxDist = 17, 
			getSimilar = False, 
			getOpposite = False
		)
		if len(self.swatches) > 0:
			self.swatches = sorted(self.swatches, key = lambda swatch : colorProcessing.stepSort(swatch.color, 8))
			for swatch in self.swatches:
				colorTuple = swatch.color.get_value_tuple()
				onInteract = lambda *args, swatch = swatch, swatches = self.swatches, scroll = self.scroll, infoBox = self.infoBox, recommendedSwatchBar = self.recommendedSwatchBar, recommendedInfoBox = self.recommendedInfoBox, currSwatchBar = self.currSwatchBar : onTouch(swatch, swatches, scroll, infoBox, recommendedSwatchBar, recommendedInfoBox, currSwatchBar, args[0], args[1])
				btn = widgets.ImageButton(source = f'imgs/{swatch.finish}.png', color = (colorTuple[0], colorTuple[1], colorTuple[2], 1), keep_ratio = True)
				btn.bind(on_touch_down = onInteract)
				self.swatchParent.add_widget(btn)
		else:
			self.swatchParent.add_widget(Label(text = 'No colors found!', halign = 'center', valign = 'middle', font_size = 30, color = app.theme_cls.primary_color))
		self.swatchParent.bind(minimum_height = self.updateHeight)
		
	def on_pre_enter(self):
		self.infoBox.close()
		self.currSwatchBar.clear()
		for swatch in currSwatches:
			colorTuple = swatch.color.get_value_tuple()
			self.currSwatchBar.addSwatch(colorTuple, swatch.finish)
			
	def onTouch(self, swatch, btn, touch):
		if btn.collide_point(*touch.pos):
			if touch.is_double_tap:
				if not swatch in currSwatches:
					self.infoBox.close()
					self.recommendedInfoBox.close()
					currSwatches.append(swatch)
					colorTuple = swatch.color.get_value_tuple()
					self.currSwatchBar.addSwatch(colorTuple, swatch.finish)
					self.recommendedSwatchBar.addRecommendedSwatches(swatch, self.swatches, self.onTouch)
					self.recommendedSwatchBar.open()
					self.scroll.size_hint_y = 0.7
			else:
				colorName = colorProcessing.getColorName(swatch.color)
				touchPos = btn.to_local(*touch.pos)
				touchPos = btn.to_window(*touchPos)
				if self.recommendedSwatchBar.isOpen and self.recommendedSwatchBar.collide_point(*touchPos):
					#arrow down
					self.recommendedInfoBox.arrowUp = False
					self.recommendedInfoBox.y = btn.top + btn.parent.spacing[1] + btn.parent.parent.y + 5
					self.recommendedInfoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
					self.recommendedInfoBox.open()
				else:
					self.recommendedSwatchBar.close()
					self.scroll.size_hint_y = 0.8
					if(touch.y > self.infoBox.height + self.currSwatchBar.height + self.recommendedSwatchBar.height):
						#arrow up
						self.infoBox.arrowUp = True
						self.infoBox.top = btn.y - btn.parent.spacing[1]
					else:
						#arrow down
						self.infoBox.arrowUp = False
						self.infoBox.y = btn.top + btn.parent.spacing[1]
					self.infoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
					self.infoBox.open()
		elif not touch.is_mouse_scrolling:
			self.infoBox.close()
			self.recommendedInfoBox.close()
			self.recommendedSwatchBar.close()
			self.scroll.size_hint_y = 0.8
					
	def updateHeight(self, *_):
		self.swatchParent.parent.height = self.swatchParent.minimum_height



class Main2Screen(Screen):
	swatchParent = ObjectProperty(None)
	infoBox = ObjectProperty(None)
	currSwatchBar = ObjectProperty(None)
	recommendedSwatchBar = ObjectProperty(None)
	recommendedInfoBox = ObjectProperty(None)
	
	def addSwatches(self, *_):
		return
		
	def on_pre_enter(self):
		self.infoBox.close()
		self.currSwatchBar.clear()
		for swatch in currSwatches:
			colorTuple = swatch.color.get_value_tuple()
			self.currSwatchBar.addSwatch(colorTuple, swatch.finish)
					
	def updateHeight(self, *_):
		self.swatchParent.parent.height = self.swatchParent.minimum_height

		
		
class AddPaletteScreen(Screen):
	cols = ObjectProperty(None)
	rows = ObjectProperty(None)
	paletteName = ObjectProperty(None)
	img = ObjectProperty(None)
	border = ObjectProperty(None)
	borderParent = ObjectProperty(None)
	
	numCols = 1
	numRows = 1
	borders = [0, 0, 0, 0]
	padding = [10, 10]
	imgSize = [0, 0]
	imgPos = (0, 0)
	
	isDragging = False	
	draggingCorner = 0
	lastPos = (0, 0)
	
	def setImg(self):
		self.cols.bind(text = self.onBoxesChange)
		self.rows.bind(text = self.onBoxesChange)
		self.border.bind(size = self.updateSize)
		self.border.bind(pos = self.updatePos)
		self.border.bind(on_touch_down = self.onTouchDown)
		self.border.bind(on_touch_up = self.onTouchUp)
		self.border.bind(on_touch_move = self.onBordersChange)
		self.img.bind(size = self.updateSrc)
		self.img.source = 'imgs/test0.jpg'
		self.borderParent.padding = self.padding
		self.borderParent.spacing = self.padding
		
	def onBoxesChange(self, *_):
		self.numCols = self.toInt(self.cols.text)
		self.borderParent.cols = self.numCols
		self.numRows = self.toInt(self.rows.text)
		self.borderParent.rows = self.numRows
		self.borderParent.clear_widgets()
		for i in range(0, self.numCols):
			for j in range(0, self.numRows):
				border = widgets.Border(color = app.theme_cls.text_color)
				border.bind(on_touch_down = self.onTouchDown)
				border.bind(on_touch_move = self.onPaddingChange)
				border.bind(on_touch_up = self.onTouchUp)
				self.borderParent.add_widget(border)
		self.updatePadding()
		
	def onTouchDown(self, border, touch):
		#0 = top-right (640, 490)	
		#1 = bottom-right (640, 10)
		#2 = top-left (160, 490)
		#3 = bottom-left (160, 10)
		self.lastPos = touch.pos
		self.isDragging = True
	
	def getDraggingCorner(self, border, touch):
		midX = border.x + (border.width / 2)
		midY = border.y + (border.height / 2)
		if touch.x >= midX and touch.y >= midY:
			self.draggingCorner = 0
		elif touch.x >= midX and touch.y < midY:
			self.draggingCorner = 1
		elif touch.x < midX and touch.y >= midY:
			self.draggingCorner = 2
		elif touch.x < midX and touch.y < midY:
			self.draggingCorner = 3
	
	def onTouchUp(self, _, touch):
		self.isDragging = False
	
	def onBordersChange(self, border, touch):
		if self.isDragging and not self.isDraggingPadding(touch.pos):
			self.getDraggingCorner(border, touch)
			diff = (touch.x - self.lastPos[0], touch.y - self.lastPos[1])
			if self.draggingCorner == 0:
				self.borders[2] -= diff[0]
				self.borders[1] -= diff[1]
			elif self.draggingCorner == 1:
				self.borders[2] -= diff[0]
				self.borders[3] += diff[1]
			elif self.draggingCorner == 2:
				self.borders[0] += diff[0]
				self.borders[1] -= diff[1]
			elif self.draggingCorner == 3:
				self.borders[0] += diff[0]
				self.borders[3] += diff[1]
			self.border.size = (self.imgSize[0] - (self.borders[0] + self.borders[2]), self.imgSize[1] - (self.borders[1] + self.borders[3]))
			self.border.pos = (self.borders[0] + self.imgPos[0], self.borders[3] + self.imgPos[1])
			self.updatePadding()
			self.lastPos = touch.pos
	
	def updatePadding(self):
		maxX = ((self.border.width / self.numCols) - 5) / 2
		maxY = ((self.border.height / self.numRows) - 5) / 2
		self.padding = [max(min(self.padding[0], maxX), 5), max(min(self.padding[1], maxY), 5)]
		self.borderParent.padding = self.padding
		self.borderParent.spacing = self.padding
	
	def onPaddingChange(self, border, touch):
		if self.isDragging and self.isDraggingPadding(touch.pos):
			self.getDraggingCorner(border, touch)
			diff = (touch.x - self.lastPos[0], touch.y - self.lastPos[1])
			if self.draggingCorner == 0:
				self.padding[0] -= diff[0]
				self.padding[1] -= diff[1]
			elif self.draggingCorner == 1:
				self.padding[0] -= diff[0]
				self.padding[1] += diff[1]
			elif self.draggingCorner == 2:
				self.padding[0] += diff[0]
				self.padding[1] -= diff[1]
			elif self.draggingCorner == 3:
				self.padding[0] += diff[0]
				self.padding[1] += diff[1]
			self.updatePadding()
			self.lastPos = touch.pos
	
	def isDraggingPadding(self, touchPos):
		borders = [self.borders[0] + self.imgPos[0], self.imgPos[1] + self.imgSize[1] - self.borders[1], self.imgPos[0] + self.imgSize[0] - self.borders[2], self.borders[3] + self.imgPos[1]]		
		if self.draggingCorner == 0:
			return (borders[2] - touchPos[0]) > (self.padding[0] - 1) and (borders[1] - touchPos[1]) > (self.padding[1] - 1)
		elif self.draggingCorner == 1:
			return (borders[2] - touchPos[0]) > (self.padding[0] - 1) and (touchPos[1] - borders[3]) > (self.padding[1] - 1)
		elif self.draggingCorner == 2:
			return (touchPos[0] - borders[0]) > (self.padding[0] - 1) and (borders[1] - touchPos[1]) > (self.padding[1] - 1)
		elif self.draggingCorner == 3:
			return (touchPos[0] - borders[0]) > (self.padding[0] - 1) and (touchPos[1] - borders[3]) > (self.padding[1] - 1)
		return False
	
	def updateSize(self, *_):
		self.borderParent.size = self.border.size
		
	def updatePos(self, *_):
		self.borderParent.pos = self.border.pos
		
	def updateSrc(self, *_):
		self.imgSize = [min(self.img.width, self.img.height)] * 2
		self.border.size = self.imgSize
		self.imgPos = (self.img.x + (self.img.pos_hint['center_x'] * self.width) - (self.imgSize[0] / 2), self.img.y)
		self.border.pos = self.imgPos

	def save(self):
		img, _, imgWidth, imgHeight = colorProcessing.loadImg(self.img.source);
		scale = imgWidth / self.imgSize[0]
		colors = []
		finishes = []
		borders = [self.borders[0] * scale, self.borders[1] * scale, self.borders[2] * scale, self.borders[3] * scale]
		padding = [self.padding[0] * scale, self.padding[1] * scale]
		width = imgWidth - (borders[0] + borders[2])
		boxWidth = width / self.numCols
		height = imgHeight - (borders[1] + borders[3])
		boxHeight = height / self.numRows
		for i in range(0, self.numCols):
			for j in range(0, self.numRows):
				left = borders[0] + (boxWidth * i) + padding[0]
				top = borders[1] + (boxHeight * j) + padding[1]
				right = borders[0] + (boxWidth * (i + 1)) - padding[0]
				btm = borders[1] + (boxHeight * (j + 1)) - padding[1]
				cropped = np.array(img.crop((left, top, right, btm)))
				colors.append(colorProcessing.avgColor(cropped).get_value_tuple())
				finishes.append(colorProcessingTF.getFinish(cropped))
		palettes = [self.paletteName.text] * len(finishes)
		save([colors, finishes, palettes])
		
	def toInt(self, val):
		try:
			num = int(val)
		except ValueError:
			return 1
		return int(val)



class ErrorScreen(Screen):
	text = ObjectProperty(None)
		
	def updateMsg(self, msg):
		self.text.text = msg



class MakeupApp(MDApp):
	#TODO: maybe change directory based on target platform?
	kv_directory = 'templates'
	
	def build(self):
		self.theme_cls.primary_palette = 'Gray'
		self.theme_cls.primary_hue = '800'
		self.theme_cls.primary_light_hue = '200'
		self.theme_cls.primary_dark_hue = 'A100'
		self.theme_cls.accent_palette = 'Indigo'
		self.screenManager = ScreenManager()
		self.lock = threading.Lock()
		screens = [
			Main0Screen(name = 'Main0Screen'),
			Main1Screen(name = 'Main1Screen'),
			Main2Screen(name = 'Main2Screen'),
			AddPaletteScreen(name = 'AddPaletteScreen'),
			ErrorScreen(name = 'ErrorScreen'),
		]
		for i in range(0, len(screens)):
			t = threading.Thread(target = self.addScreen, args = (screens[i], ), daemon = True)
			t.start()
		return self.screenManager
		
	def addScreen(self, screenClass):
		with self.lock:
			self.screenManager.add_widget(screenClass)
		
	def setScreen(self, screen):
		app.screenManager.current = screen



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

def loadFormatted():
	info = load()
	swatches = []
	for i in info:
		line = i.split(',')
		swatches.append(swatch.Swatch((line[0], line[1], line[2]), line[3], line[4]))
	return sorted(swatches, key = lambda swatch : colorProcessing.stepSort(swatch.color, 8))
	
def displayError(msg):
	app.errorScreen.update(msg)
	app.setScreen('Error')
	Clock.schedule_once(sys.exit, 10)
		
def loadColorProcessingTF():
	global colorProcessingTF
	colorProcessingTF = __import__('colorProcessingTF')
	
def onTouch(swatch, swatches, scroll, infoBox, recommendedSwatchBar, recommendedInfoBox, currSwatchBar, btn, touch):
	if btn.collide_point(*touch.pos):
		if touch.is_double_tap:
			if not swatch in currSwatches:
				infoBox.close()
				recommendedInfoBox.close()
				currSwatches.append(swatch)
				colorTuple = swatch.color.get_value_tuple()
				currSwatchBar.addSwatch(colorTuple, swatch.finish)
				onInteract = lambda swatch, btn, touch, swatches = swatches, scroll = scroll, infoBox = infoBox, recommendedSwatchBar = recommendedSwatchBar, recommendedInfoBox = recommendedInfoBox, currSwatchBar = currSwatchBar : onTouch(swatch, swatches, scroll, infoBox, recommendedSwatchBar, recommendedInfoBox, currSwatchBar, btn, touch)
				recommendedSwatchBar.addRecommendedSwatches(swatch, swatches, onInteract)
				recommendedSwatchBar.open()
				scroll.size_hint_y = 0.7
		else:
			colorName = colorProcessing.getColorName(swatch.color)
			touchPos = btn.to_local(*touch.pos)
			touchPos = btn.to_window(*touchPos)
			if recommendedSwatchBar.isOpen and recommendedSwatchBar.collide_point(*touchPos):
				#arrow down
				recommendedInfoBox.arrowUp = False
				recommendedInfoBox.y = btn.top + btn.parent.spacing[1] + btn.parent.parent.y + 5
				recommendedInfoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
				recommendedInfoBox.open()
			else:
				recommendedSwatchBar.close()
				scroll.size_hint_y = 0.8
				if(touch.y > infoBox.height + currSwatchBar.height + recommendedSwatchBar.height):
					#arrow up
					infoBox.arrowUp = True
					infoBox.top = btn.y - btn.parent.spacing[1]
				else:
					#arrow down
					infoBox.arrowUp = False
					infoBox.y = btn.top + btn.parent.spacing[1]
				infoBox.updateInfo(colorName, swatch.finish, swatch.palette, btn.center_x)
				infoBox.open()
				
if __name__ == '__main__':
	currSwatches = []
	t = threading.Thread(target = loadColorProcessingTF, daemon = True)
	t.start()
	app = MakeupApp()
	app.run()