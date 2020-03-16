import numpy as np
import tensorflow as tf
import cv2

model = tf.keras.models.load_model('training/finishes-0.001-5-50-2conv.h5')

def getFinish(img):
	newImg = cv2.resize(cv2.cvtColor(img, cv2.COLOR_RGB2GRAY), (32, 32)) / 255.0
	newImg = newImg.reshape(-1, 32, 32, 1)
	print(img.shape)
	print(newImg.shape)
	print(newImg)
	prediction = np.argmax(model.predict(newImg))
	if prediction == 0:
		return 'matte'
	elif prediction == 1:
		return 'satin'
	elif prediction == 2:
		return 'shimmer'
	elif prediction == 3:
		return 'metallic'
	elif prediction == 4:
		return 'glitter'
	else:
		return 'other'
