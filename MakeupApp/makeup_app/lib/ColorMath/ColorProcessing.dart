import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import '../Widgets/Swatch.dart';
import '../globals.dart' as globals;
import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import 'ColorSorting.dart';

Future<Image> loadImg(String path) async {
  //return decodeImage(File(path.replaceAll('/', '\\')).readAsBytesSync());
  if(globals.debug) {
    ByteData data = await rootBundle.load(path);
    return decodeImage(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
  File f = File(path);
  Uint8List bytes = await f.readAsBytes();
  ByteData data = ByteData.view(bytes.buffer);
  return decodeImage(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

RGBColor avgColor(Image img) {
  List<int> totalColor = [0, 0, 0];
  List<int> pxs = img.data;
  for(int x = 0; x < img.width; x++) {
    for(int y = 0; y < img.height; y++) {
      int color = pxs[y * img.width + x];
      totalColor[0] += (color) & 0xff;
      totalColor[1] += (color >> 8) & 0xff;
      totalColor[2] += (color >> 16) & 0xff;
    }
  }
  int size = (img.width * img.height);
  return RGBColor(totalColor[0] / size / 255.0, totalColor[1] / size / 255.0, totalColor[2] / size / 255.0);
}

RGBColor maxColor(Image img) {
  List<RGBColor> colors = [];
  List<int> numOccurrences = [];
  List<int> pxs = img.getBytes(format: Format.rgb);
  for(int x = 0; x < img.width; x++) {
    for(int y = 0; y < img.height; y++) {
      bool found = false;
      for(int i = 0; i < colors.length; i++) {
        List<double> values = colors[i].getValues();
        int index = (y * img.width + x) * 3;
        if(values[0] == pxs[index + 0] && values[1] == pxs[index + 1] && values[2] == pxs[index + 2]) {
          numOccurrences[i]++;
          found = true;
          break;
        }
      }
      if(!found) {
        int index = (y * img.width + x) * 3;
        colors.add(RGBColor(pxs[index + 0] / 255.0, pxs[index + 1] / 255.0, pxs[index + 2] / 255.0));
        numOccurrences.add(1);
      }
    }
  }
  return colors[numOccurrences.indexOf(numOccurrences.reduce(max))];
}

RGBColor maxFiveColor(Image img) {
  List<RGBColor> colors = [];
  List<int> numOccurrences = [];
  List<int> pxs = img.getBytes(format: Format.rgb);
  for(int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      bool found = false;
      for(int i = 0; i < colors.length; i++) {
        List<double> values = colors[i].getValues();
        int index = (y * img.width + x) * 3;
        if(values[0] == pxs[index + 0] && values[1] == pxs[index + 1] && values[2] == pxs[index + 2]) {
          numOccurrences[i]++;
          found = true;
          break;
        }
      }
      if(!found) {
        int index = (y * img.width + x) * 3;
        colors.add(RGBColor(pxs[index + 0] / 255.0, pxs[index + 1] / 255.0, pxs[index + 2] / 255.0));
        numOccurrences.add(1);
      }
    }
  }
  List<int> sortedNumOccurrences = List.from(numOccurrences);
  sortedNumOccurrences.sort((int a, int b) => -a.compareTo(b));
  int size = max(5, sortedNumOccurrences.length);
  List<double> totalColor = [0, 0, 0];
  for(int i = 0; i < size; i++) {
    Map<String, double> color = colors[numOccurrences.indexOf(sortedNumOccurrences[i])].values;
    totalColor[0] += color['rgbR'];
    totalColor[1] += color['rgbG'];
    totalColor[2] += color['rgbB'];
  }
  return RGBColor(totalColor[0] / size, totalColor[1] / size, totalColor[2] / size);
}

String getColorName(RGBColor rgb) {
  Map<String, RGBColor> colorWheel = createColorWheel();
  double minDist = 1000;
  String minColor = 'unknown';
  LabColor color0 = RGBtoLab(rgb);
  List<String> keys = colorWheel.keys.toList();
  for(int i = 0; i < keys.length; i++) {
    String color = keys[i];
    LabColor color1 = RGBtoLab(colorWheel[color]);
    double dist = deltaECie2000(color0, color1);
    if(dist < minDist) {
      minDist = dist;
      minColor = color;
    }
  }
  return minColor;
}

Map<Swatch, int> getSimilarColors(RGBColor rgb, Swatch rgbSwatch, List<Swatch> swatches, { double maxDist = 15, bool getSimilar = true, bool getOpposite = true }) {
  String colorName = getColorName(rgb);
  LabColor color0 = RGBtoLab(rgb);
  List<String> similarCategories = [];
  List<String> oppositeCategories = [];
  Map<Swatch, int> newSwatches = {};
  if(getSimilar) {
    similarCategories = createSimilarColorNames()[colorName];
  }
  if(getOpposite) {
    oppositeCategories = createOppositeColorNames()[colorName];
  }
  for(int i = 0; i < swatches.length; i++) {
    double dist = deltaECie2000(color0, RGBtoLab(swatches[i].color));
    if(rgbSwatch != null && dist == 0 && swatches[i].finish == rgbSwatch.finish && swatches[i].palette == rgbSwatch.palette) {
      continue;
    }
    if(dist < maxDist) {
      newSwatches[swatches[i]] = 10;
      continue;
    }
    String colorName = '';
    if(getSimilar || getOpposite) {
      colorName = getColorName(swatches[i].color);
    }
    if(getSimilar && similarCategories.contains(colorName)) {
      newSwatches[swatches[i]] = 5;
      continue;
    }
    if(getOpposite && oppositeCategories.contains(colorName)) {
      newSwatches[swatches[i]] = 1;
      continue;
    }
  }
  return newSwatches;
}

