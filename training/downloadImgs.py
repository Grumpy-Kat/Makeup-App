from google_images_download import google_images_download
import sys

def downloadImgs(query, num):
	response = google_images_download.googleimagesdownload()
	args = {
		'keywords': query + ' eyeshadow singles',
		'format': 'jpg',
		'limit': int(num),
		'print_urls': True,
		'chromedriver': r'C:\Users\Luda\Desktop\Makeup\training\chromedriver.exe',
		'output_directory': r'C:\Users\Luda\Desktop\Makeup\training\finishes',
		'image_directory': query
	}
	result = []
	while(len(result) == 0 or len(result[0][query + ' eyeshadow singles']) == 0):
		result = response.download(args)

if __name__ == '__main__':
	print(sys.argv[1] + " " + sys.argv[2])
	downloadImgs(sys.argv[1], sys.argv[2])