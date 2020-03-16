import 'package:tflite/tflite.dart';
import 'package:image/image.dart';
import 'dart:math';
import 'dart:typed_data';
import '../globals.dart' as globals;

void getModel() async {
  globals.model = await Tflite.loadModel(model: 'training/finishes-0.001-5-50-2conv.tflite');
}

Future<String> getFinish(Image img) async {
  Image newImg = copyResizeCropSquare(grayscale(img), 32);
  Float32List convertedBytes = Float32List(1 * newImg.width * newImg.height * 1);
  Float32List buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < newImg.width; i++) {
    for (var j = 0; j < newImg.height; j++) {
      int pixel = newImg.getPixel(j, i);
      buffer[pixelIndex++] = getRed(pixel) / 255.0;
    }
  }
  List<int> result = await Tflite.runModelOnBinary(binary: convertedBytes.buffer.asUint8List(), numResults: 5, asynch: true);
  int prediction = result.reduce(max);
  switch(prediction) {
    case 0:
      return 'matte';
    case 1:
      return 'satin';
    case 2:
      return 'shimmer';
    case 3:
      return 'metallic';
    case 4:
      return 'glitter';
  }
  return 'other';
}
