import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:image/image.dart';
import 'dart:async';

Interpreter? interpreter;
int downloadAttempts = 0;
List<String> labels = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];

Future<bool> getModel() async {
  if(interpreter != null) {
    // Already downloaded, nothing to be done
    return false;
  }
  FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(
    androidWifiRequired: false,
    iosAllowsCellularAccess: true,
    iosAllowsBackgroundDownloading: true,
  );

  bool hadException = false;
  // Don't attempt too long if most likely won't work
  await (FirebaseModelDownloader.instance.getModel('Finish-Detection', FirebaseModelDownloadType.latestModel, conditions)
    .timeout(Duration(seconds: (downloadAttempts >= 3 ? 1 : 3)))
    .then(
      (FirebaseCustomModel model) async {
        interpreter = Interpreter.fromFile(model.file);
      },
      onError: (e) async {
        downloadAttempts++;
        hadException = true;
      }
    )
  );

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
  List output = List.filled(1 * 5, 0.0).reshape([1, 5]);
  interpreter!.run(input, output);
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