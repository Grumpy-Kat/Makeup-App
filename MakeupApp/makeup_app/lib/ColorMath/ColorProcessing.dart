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
    for (int y = 0; y < img.height; y++) {
      for (int i = 0; i < colors.length; y++) {
        List<double> values = colors[i].getValues();
        int index = (y * img.width + x) * 3;
        if(values[0] == pxs[index + 0] && values[1] == pxs[index + 1] && values[2] == pxs[index + 2]) {
          numOccurrences[i]++;
          break;
        } else {
          colors.add(RGBColor(pxs[index + 0] / 255.0, pxs[index + 1] / 255.0, pxs[index + 2] / 255.0));
          numOccurrences.add(1);
        }
      }
    }
  }
  return colors[numOccurrences.indexOf(numOccurrences.reduce(max))];
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
  Map<String, RGBColor> colorWheel = createColorWheel();
  //List<String> categories = colorWheel.keys.toList();
  //int index = categories.indexOf(colorName);
  List<String> similarCategories = [];
  List<String> oppositeCategories = [];
  Map<Swatch, int> newSwatches = {};
  if(getSimilar) {
    similarCategories = createSimilarColorNames()[colorName];
    /*if(index < 3) {
      //white/black/gray
      similarCategories = [categories[0], categories[1], categories[2]];
    } else {
      for(int i = index - 3; i < index + 4; i++) {
        if(i < 3) {
          similarCategories.add(categories[i - 3 + categories.length]);
        } else if(i > categories.length - 1) {
          similarCategories.add(categories[(i % 3) + 3]);
        } else {
          similarCategories.add(categories[i]);
        }
      }
    }*/
  }
  if(getOpposite) {
    oppositeCategories = createOppositeColorNames()[colorName];
    /*if (index < 3) {
      //white/black/gray
      oppositeCategories = [];
    } else {
      int oppIndex = ((index < categories.length / 2) ? (index + (categories.length / 2)) : (index - (categories.length / 2))).toInt();
      for (int i = oppIndex - 1; i < oppIndex + 2; i++) {
        if (i < 3) {
          oppositeCategories.add(categories[i - 3 + categories.length]);
        } else if (i > categories.length - 1) {
          oppositeCategories.add(categories[(i % 3) + 3]);
        } else {
          oppositeCategories.add(categories[i]);
        }
      }
    }*/
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

