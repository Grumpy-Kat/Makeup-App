import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_custom/firebase_ml_custom.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'dart:async';

FirebaseCustomRemoteModel? model;
Interpreter? interpreter;
int downloadAttempts = 0;
List<String> labels = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];

Future<bool> getModel() async {
  if(interpreter != null) {
    //already downloaded, nothing to be done
    return false;
  }
  model = FirebaseCustomRemoteModel('Finish-Detection');
  FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(
    androidRequireWifi: false,
    iosAllowCellularAccess: true,
    iosAllowBackgroundDownloading: true,
  );
  FirebaseModelManager manager = FirebaseModelManager.instance;
  bool hadException = false;
  //don't attempt too long if most likely won't work
  await (manager.download(model, conditions).timeout(Duration(seconds: (downloadAttempts >= 3 ? 1 : 3))).then(
    (value) async {
      bool canContinue = false;
      do {
        canContinue = await manager.isModelDownloaded(model);
      } while(!canContinue);
      File modelFile = await manager.getLatestModelFile(model);
      interpreter = Interpreter.fromFile(modelFile);
    },
    onError: (e) async {
      downloadAttempts++;
      hadException = true;
    }
  ));
  return hadException;
}

Future<String> getFinish(Image img) async {
  bool hadException = await getModel();
  if(hadException) {
    if(interpreter == null) {
      print('Unable to get internet');
      return labels[0];
    } else {
      return await _getFinishActual(img);
    }
  } else {
    return await _getFinishActual(img);
  }
}

Future<String> _getFinishActual(Image img) async {
  Image newImg = copyResize(grayscale(img), width: 32, height: 32);
  List<List<List<List<double>>>> input = [List<List<List<double>>>.filled(newImg.height, [])];
  for(var x = 0; x < newImg.height; x++) {
    input[0][x] = List<List<double>>.filled(newImg.width, []);
    for(var y = 0; y < newImg.width; y++) {
      int pixel = newImg.getPixel(y, x);
      input[0][x][y] = [getRed(pixel) / 255.0];
    }
  }
  //print(input);
  List output = List.filled(1 * 5, 0.0).reshape([1, 5]);
  interpreter!.run(input, output);
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