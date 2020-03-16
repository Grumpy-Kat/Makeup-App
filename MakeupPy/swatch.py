from colormath.color_objects import sRGBColor

class Swatch:
	def __init__(self, color, finish, palette):
		self.color = sRGBColor(float(color[0]), float(color[1]), float(color[2]), False)
		self.finish = finish
		self.palette = palette