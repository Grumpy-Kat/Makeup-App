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
  FirebaseModelManager manager = FirebaseModelManager.instance;
  await manager.download(model, conditions);
  bool canContinue = await manager.isModelDownloaded(model);
  while(!canContinue) {
    canContinue = await manager.isModelDownloaded(model);
  }
  File modelFile = await manager.getLatestModelFile(model);
  interpreter = Interpreter.fromFile(modelFile);
}

Future<String> getFinish(Image img) async {
  if(interpreter == null) {
    await getModel();
  }
  Image newImg = copyResize(grayscale(img), width: 32, height: 32);
  List<List<List<List<double>>>> input = [List<List<List<double>>>(newImg.height)];
  for(var x = 0; x < newImg.height; x++) {
    input[0][x] = List<List<double>>(newImg.width);
    for(var y = 0; y < newImg.width; y++) {
      int pixel = newImg.getPixel(y, x);
      input[0][x][y] = [getRed(pixel) / 255.0];
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
