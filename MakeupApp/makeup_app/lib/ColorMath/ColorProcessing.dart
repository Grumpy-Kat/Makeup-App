import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import '../Widgets/Swatch.dart';
import '../globals.dart' as globals;

Map<String, RGBColor> createColorWheel() {
  Map<String, RGBColor> colorWheel = Map<String, RGBColor>();
  colorWheel['white'] = RGBColor(1, 1, 1);
  colorWheel['gray'] = RGBColor(0.5, 0.5, 0.5);
  colorWheel['black'] = RGBColor(0, 0, 0);
  colorWheel['light red'] = RGBColor(1, 0.8, 0.8);
  colorWheel['red'] = RGBColor(1, 0, 0);
  colorWheel['dark red'] = RGBColor(0.2, 0, 0);
  colorWheel['light orange'] = RGBColor(1, 0.9, 0.8);
  colorWheel['orange'] = RGBColor(1, 0.5, 0);
  colorWheel['dark orange'] = RGBColor(0.2, 0.1, 0);
  colorWheel['light yellow'] = RGBColor(1, 1, 0.8);
  colorWheel['yellow'] = RGBColor(1, 1, 0);
  colorWheel['dark yellow'] = RGBColor(0.2, 0.2, 0);
  colorWheel['light chartreuse'] = RGBColor(0.9, 1, 0.8);
  colorWheel['chartreuse'] = RGBColor(0.5, 1, 0);
  colorWheel['dark chartreuse'] = RGBColor(0.1, 0.2, 0);
  colorWheel['light green'] = RGBColor(0.8, 1, 0.8);
  colorWheel['green'] = RGBColor(0, 1, 0);
  colorWheel['dark green'] = RGBColor(0, 0.2, 0);
  colorWheel['light spring green'] = RGBColor(0.8, 1, 0.9);
  colorWheel['spring green'] = RGBColor(0, 1, 0.5);
  colorWheel['dark spring green'] = RGBColor(0, 0.2, 0.1);
  colorWheel['light aqua'] = RGBColor(0.8, 1, 1);
  colorWheel['aqua'] = RGBColor(0, 1, 1);
  colorWheel['dark aqua'] = RGBColor(0, 0.2, 0.2);
  colorWheel['light dodger blue'] = RGBColor(0.8, 0.9, 1);
  colorWheel['dodger blue'] = RGBColor(0, 0.5, 1);
  colorWheel['dark dodger blue'] = RGBColor(0, 0.1, 0.2);
  colorWheel['light blue'] = RGBColor(0.8, 0.8, 1);
  colorWheel['blue'] = RGBColor(0, 1, 1);
  colorWheel['dark blue'] = RGBColor(0, 0, 0.2);
  colorWheel['light indigo'] = RGBColor(0.9, 0.8, 1);
  colorWheel['indigo'] = RGBColor(0.5, 0, 1);
  colorWheel['dark indigo'] = RGBColor(0.1, 0, 0.2);
  colorWheel['light purple'] = RGBColor(1, 0.8, 1);
  colorWheel['purple'] = RGBColor(1, 0, 1);
  colorWheel['dark purple'] = RGBColor(0.2, 0, 0.2);
  colorWheel['light violet'] = RGBColor(1, 0.8, 0.9);
  colorWheel['violet'] = RGBColor(1, 0, 0.5);
  colorWheel['dark violet'] = RGBColor(0.2, 0, 0.1);
  return colorWheel;
}

List<double> stepSort(RGBColor rgb, { int step = 1 }) {
  List<double> val = rgb.getValues();
  double threshold = 0.085;
  bool isGray = ((val[0] - val[1]).abs() < threshold && (val[0] - val[2]).abs() < threshold && (val[1] - val[2]).abs() < threshold);
  List<double> hsvVal = RGBtoHSV(rgb).getValues();
  double lum = 0.241 * val[0] + 0.691 * val[1] + 0.068 * val[2];
  double h2 = hsvVal[0] * step;
  double lum2 = lum * step;
  double v2 = hsvVal[1] * step;
  //isGray: 0 - 1
  //lum2: 0 - (360 * step)
  //h2: 0 - step
  //v2: 0 - step
  if(isGray) {
    return [0, lum2, v2, h2];
  }
  return [1, h2, lum2, v2];
}

List<double> finishSort(Swatch swatch, { int step = 1, String firstFinish = '' }) {
  List<double> sort = stepSort(swatch.color, step: step);
  double finish = 10;
  switch(swatch.finish) {
    case 'matte':
      finish = 1;
      break;
    case 'satin':
      finish = 2;
      break;
    case 'shimmer':
      finish = 3;
      break;
    case 'mettallic':
      finish = 4;
      break;
    case 'glitter':
      finish = 5;
      break;
    default:
      finish = 10;
      break;
  }
  if(swatch.finish == firstFinish) {
    finish = 0;
  }
  //finish: 0 - 10
  //isGray: 0 - 1
  //lum2: 0 - (360 * step)
  //h2: 0 - step
  //v2: 0 - step
  return [finish, sort[0], sort[1], sort[2], sort[3]];
}

List<double> paletteSort(Swatch swatch, List<Swatch> swatches, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<String> palettes = [];
  for(int i = 0; i < swatches.length; i++) {
    if(!palettes.contains(swatches[i].palette)) {
      palettes.add(swatches[i].palette);
    }
  }
  //palette: 0 - (palettes.length - 1)
  //isGray: 0 - 1
  //lum2: 0 - (360 * step)
  //h2: 0 - step
  //v2: 0 - step
  return [palettes.indexOf(swatch.palette).toDouble(), sort[0], sort[1], sort[2], sort[3]];
}

List<double> brandSort(Swatch swatch, List<Swatch> swatches, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<String> brands = [];
  for(int i = 0; i < swatches.length; i++) {
    if(!brands.contains(swatches[i].brand)) {
      brands.add(swatches[i].brand);
    }
  }
  //palette: 0 - (palettes.length - 1)
  //isGray: 0 - 1
  //lum2: 0 - (360 * step)
  //h2: 0 - step
  //v2: 0 - step
  return [brands.indexOf(swatch.brand).toDouble(), sort[0], sort[1], sort[2], sort[3]];
}

List<double> colorSort(RGBColor rgb) {
  List<double> val = rgb.getValues();
  LabColor color0 = RGBtoLab(rgb);
  double threshold = 0.085;
  bool isGray = ((val[0] - val[1]).abs() < threshold && (val[0] - val[2]).abs() < threshold && (val[1] - val[2]).abs() < threshold);
  //isGray: 0 - 1
  //diff: 0 - 100
  if(isGray) {
    LabColor color1 = RGBtoLab(RGBColor(0, 0, 0));
    return [0, deltaECie2000(color0, color1)];
  }
  LabColor color1 = RGBtoLab(RGBColor(1, 0, 0));
  return [1, deltaECie2000(color0, color1)];
}

List<double> distanceSort(RGBColor rgb, RGBColor org) {
  //diff: 0 - 100
  return [deltaECie2000(RGBtoLab(rgb), RGBtoLab(org))];
}

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

List<Swatch> getSimilarColors(RGBColor rgb, Swatch rgbSwatch, List<Swatch> swatches, { double maxDist = 15, bool getSimilar = true, bool getOpposite = true }) {
  String colorName = getColorName(rgb);
  LabColor color0 = RGBtoLab(rgb);
  Map<String, RGBColor> colorWheel = createColorWheel();
  List<String> categories = colorWheel.keys.toList();
  int index = categories.indexOf(colorName);
  List<String> similarCategories = [];
  List<String> oppositeCategories = [];
  List<Swatch> newSwatches = [];
  if(getSimilar) {
    if(index < 3) {
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
    }
  }
  if(getOpposite) {
    if (index < 3) {
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
    }
  }
  for(int i = 0; i < swatches.length; i++) {
    double dist = deltaECie2000(color0, RGBtoLab(swatches[i].color));
    if(rgbSwatch != null && dist == 0 && swatches[i].finish == rgbSwatch.finish && swatches[i].palette == rgbSwatch.palette) {
      continue;
    }
    if(dist < maxDist) {
      newSwatches.add(swatches[i]);
      continue;
    }
    String colorName = '';
    if(getSimilar || getOpposite) {
      colorName = getColorName(swatches[i].color);
    }
    if(getSimilar) {
      if(similarCategories.contains(colorName)) {
        newSwatches.add(swatches[i]);
        continue;
      }
    }
    if(getOpposite) {
      if(oppositeCategories.contains(colorName)) {
        newSwatches.add(swatches[i]);
        continue;
      }
    }
  }
  return newSwatches;
}

