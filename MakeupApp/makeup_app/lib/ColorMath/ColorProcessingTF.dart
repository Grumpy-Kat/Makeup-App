import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_custom/firebase_ml_custom.dart';
import 'package:image/image.dart';
import 'dart:io';

FirebaseCustomRemoteModel model;
Interpreter interpreter;
List<String> labels = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];

Future<void> getModel() async {
  model = FirebaseCustomRemoteModel('Finish-Detection');
  FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(
    androidRequireWifi: true,
    iosAllowCellularAccess: true,
    iosAllowBackgroundDownloading: true,
  );
  await FirebaseModelManager.instance.download(model, conditions);
  File modelFile = await FirebaseModelManager.instance.getLatestModelFile(model);
  interpreter = Interpreter.fromFile(modelFile);
}

Future<String> getFinish(Image img) async {
  if(interpreter == null) {
    await getModel();
  }
  Image newImg = copyResize(grayscale(img), width: 32, height: 32);
  List<List<List<List<double>>>> input = [List<List<List<double>>>(newImg.height)];
  for(var i = 0; i < newImg.height; i++) {
    input[0][i] = List<List<double>>(newImg.width);
    for(var j = 0; j < newImg.width; j++) {
      int pixel = newImg.getPixel(j, i);
      input[0][i][j] = [getRed(pixel) / 255.0];
    }
  }
  //print(input);
  List output = List(1 * 5).reshape([1, 5]);
  interpreter.run(input, output);
  //print(output);
  int index = 0;
  for(int i = 1; i < output[0].length; i++) {
    if(output[0][i] > output[0][index]) {
      index = i;
    }
  }
  String finishResult = labels[index];
  print('Prediction $finishResult');
  return finishResult;
}
