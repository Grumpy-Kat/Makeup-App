import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Activation, Flatten, Conv2D, MaxPooling2D
from tensorflow.keras.callbacks import TensorBoard
from tensorflow.keras.backend import clear_session
from random import shuffle
import os

IMG_ROOT_DIR = r'C:\Users\Luda\Desktop\Makeup\training\finishes'
IMG_SIZE = 32
#IMG_SIZE = 45
LR = 1e-3
SPLIT_RATE = 0.2
BATCH_SIZE = 5
EPOCHS = 50
MODEL_NAME = 'finishes-{}-{}-{}-{}'.format(LR, BATCH_SIZE, EPOCHS, '2conv')
LABEL_TYPES = 5

def getData():
	if os.path.exists('data-{}.npy'.format(IMG_SIZE)):
		return np.load('data-{}.npy'.format(IMG_SIZE), allow_pickle = True)
	data = []
	for dir in os.listdir(IMG_ROOT_DIR):
		label = [0] * len(os.listdir(IMG_ROOT_DIR))
		label[int(dir.split('.')[0])] = 1
		for img in os.listdir(os.path.join(IMG_ROOT_DIR, dir)):
			path = os.path.join(IMG_ROOT_DIR, dir, img)
			img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
			img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
			data.append([np.array(img) / 255.0, np.array(label)])
	shuffle(data)
	np.save('data-{}.npy'.format(IMG_SIZE), data)
	return data

def trainModel():
	clear_session()
	
	data = getData()
	x = np.array([i[0] for i in data]).reshape(-1, IMG_SIZE, IMG_SIZE, 1)
	y = [i[1] for i in data]
	
	model = Sequential()
	
	model.add(Conv2D(32, (3, 3), input_shape = (IMG_SIZE, IMG_SIZE, 1)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size = (2, 2)))
	
	model.add(Conv2D(64, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size = (2, 2)))
	
	model.add(Flatten())
	model.add(Dense(1024))
	model.add(Activation('relu'))
	
	model.add(Dense(LABEL_TYPES))
	model.add(Activation('softmax'))
	
	tensorboard = TensorBoard(log_dir = 'logs\{}'.format(MODEL_NAME))
	model.compile(loss = 'categorical_crossentropy', optimizer = 'adam', learning_rate = LR, metrics=['accuracy'])

	model.summary()
	model.fit(np.array(x), np.array(y), batch_size = BATCH_SIZE, epochs = EPOCHS, validation_split = SPLIT_RATE, callbacks = [tensorboard])
	return model

if __name__ == '__main__':
	model = trainModel()
	model.save(MODEL_NAME + '.h5')