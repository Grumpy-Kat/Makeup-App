from kivy.uix.button import ButtonBehavior
from kivy.uix.image import Image
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.widget import Widget
from kivy.properties import ObjectProperty, BooleanProperty, NumericProperty, ListProperty
import string
import colorProcessing
		


class ImageButton(ButtonBehavior, Image):
	pass



class Border(FloatLayout):
	color = ListProperty((0, 0, 0, 1))
	
	def __init__(self, **kwargs):
		super().__init__(**kwargs)
		if 'color' in kwargs:
			self.color = kwargs['color']



class MenuBar(BoxLayout):
	pass



class InfoBox(BoxLayout):
	arrowX = NumericProperty(0)
	arrowWidth = NumericProperty(10)
	arrowHeight = NumericProperty(13)
	arrowUp = BooleanProperty(True)
	arrowPoints = ListProperty()

	def __init__(self, **kwargs):
		super().__init__(**kwargs)
		self.orientation = 'vertical'
		self.margin = 20
		self.updatePoints()
		self.bind(y = self.updatePoints)
		self.bind(arrowX = self.updatePoints)
		self.bind(arrowUp = self.updatePoints)
		
		self.colorText = Label(text = 'Color: ', halign = 'left', valign = 'middle')
		self.colorText.bind(width = self.updateWidth)
		self.add_widget(self.colorText)
		
		self.finishText = Label(text = 'Finish: ', halign = 'left', valign = 'middle')
		self.finishText.bind(width = self.updateWidth)
		self.add_widget(self.finishText)
		
		self.paletteText = Label(text = 'Palette: ', halign = 'left', valign = 'middle')
		self.paletteText.bind(width = self.updateWidth)
		self.add_widget(self.paletteText)
		
	def updateInfo(self, color, finish, palette, x):
		self.colorText.text = 'Color: ' + string.capwords(color)
		self.finishText.text = 'Finish: ' + string.capwords(finish)
		self.paletteText.text = 'Palette: ' + string.capwords(palette)
		self.arrowX = x
		
	def updateWidth(self, text, *args):
		text.text_size = (text.width - self.margin, None)
		
	def updatePoints(self, *args):
		if self.arrowUp:
			self.arrowPoints = [self.arrowX - self.arrowWidth, self.top, self.arrowX, self.top + self.arrowHeight, self.arrowX + self.arrowWidth, self.top]
		else:
			self.arrowPoints = [self.arrowX - self.arrowWidth, self.y, self.arrowX, self.y - self.arrowHeight, self.arrowX + self.arrowWidth, self.y]	
		
	def open(self):
		self.opacity = 1
		self.disabled = False
	
	def close(self):
		self.opacity = 0
		self.disabled = True



class CurrSwatchBar(FloatLayout):
	swatchParent = ObjectProperty(None)
	
	def addSwatch(self, colorTuple, finish):
		self.swatchParent.add_widget(ImageButton(source = f'imgs/{finish}.png', color = (colorTuple[0], colorTuple[1], colorTuple[2], 1), keep_ratio = True))
	
	def clear(self):
		self.swatchParent.clear_widgets()



class RecommendedSwatchBar(FloatLayout):
	swatchParent = ObjectProperty(None)
	isOpen = False
	
	def addRecommendedSwatches(self, swatch, swatches, onInteract):
		self.clear()
		recommendedSwatches = colorProcessing.getSimilarColors(
			rgb = swatch.color,
			rgbSwatch = swatch,
			swatches = swatches,
			maxDist = 10,
			getSimilar = True, 
			getOpposite = True
		)
		if len(recommendedSwatches) > 0:
			recommendedSwatches = sorted(recommendedSwatches, key = lambda recommendedSwatch : colorProcessing.finishSort(recommendedSwatch, 8, swatch.finish))
			for recommendedSwatch in recommendedSwatches:
				colorTuple = recommendedSwatch.color.get_value_tuple()
				onTouch = lambda *args, recommendedSwatch = recommendedSwatch : onInteract(recommendedSwatch, args[0], args[1])
				btn = ImageButton(source = f'imgs/{recommendedSwatch.finish}.png', color = (colorTuple[0], colorTuple[1], colorTuple[2], 1), keep_ratio = True)
				btn.bind(on_touch_down = onTouch)
				self.swatchParent.add_widget(btn)
				
	def clear(self):
		self.swatchParent.clear_widgets()
		
	def open(self):
		self.opacity = 1
		self.disabled = False
		self.isOpen = True
	
	def close(self):
		self.opacity = 0
		self.disabled = True
		self.isOpen = False
