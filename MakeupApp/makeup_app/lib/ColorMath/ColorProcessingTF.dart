import 'package:tflite/tflite.dart';
import 'package:image/image.dart';
import 'dart:typed_data';
import '../globals.dart' as globals;

Future<String> getModel() async {
  print('loadModel');
  globals.model = await Tflite.loadModel(model: 'training/finishes-0.001-5-50-2conv.tflite', labels: 'training/labels.txt');
  return globals.model;
}

Future<String> getFinish(Image img) async {
  if(globals.model == '') {
    print(await getModel());
  }
  Image newImg = copyResize(grayscale(img), width: 32, height: 32);
  Float32List convertedBytes = Float32List(1 * newImg.width * newImg.height * 1);
  Float32List buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < newImg.width; i++) {
    for (var j = 0; j < newImg.height; j++) {
      int pixel = newImg.getPixel(j, i);
      buffer[pixelIndex++] = getRed(pixel) / 255.0;
    }
  }
  List<dynamic> result = await Tflite.runModelOnBinary(binary: convertedBytes.buffer.asUint8List(), numResults: 5);
  List<String> finishResults = result[0]['label'].split(' ');
  print('Prediction ${finishResults.last}');
  return finishResults.last;
}
