import 'dart:math';
import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import '../Widgets/Swatch.dart';

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
  double v2 = hsvVal[2] * step;
  //isGray: 0 - 1
  //v2: 0 - step
  //h2: 0 - step
  //lum2: 0 - (360 * step)
  if(isGray) {
    return [1, h2, v2, lum2];
  }
  return [0, h2, v2, lum2];
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
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [finish, sort[0], sort[1], sort[2], sort[3]];
}

double round(double val) {
  //rounds to certain step
  return ((val * 2).round().toDouble() / 2);
}

List<double> lightestSort(Swatch swatch, { int step = 1 }) {
  List<double> sort = darkestSort(swatch, step: step);
  //v: 0 - 1
  //s: 0 - step
  //h2: 0 - step
  //lum2: 0 - (360 * step)
  return [step - sort[0], step - sort[1], sort[2], sort[2]];
}

List<double> darkestSort(Swatch swatch, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<double> hsvVal = RGBtoHSV(swatch.color).getValues();
  double v = ((hsvVal[2] * 2).round().toDouble() / 2) * step;
  double s = hsvVal[1] * step;
  if(v > step / 2) {
    s = step - s;
  }
  //v: 0 - step
  //s: 0 - step
  //h2: 0 - step
  //lum2: 0 - (360 * step)
  return [v, s, sort[1], sort[2]];
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
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
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
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [brands.indexOf(swatch.brand).toDouble(), sort[0], sort[1], sort[2], sort[3]];
}

List<double> highestRatedSort(Swatch swatch, { int step = 1}) {
  List<double> sort = stepSort(swatch.color, step: step);
  double rating = 10.0 - swatch.rating;
  //rating: 1 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [rating, sort[0], sort[1], sort[2], sort[3]];
}

List<double> lowestRatedSort(Swatch swatch, { int step = 1}) {
  List<double> sort = stepSort(swatch.color, step: step);
  double rating = swatch.rating.toDouble();
  //rating: 1 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [rating, sort[0], sort[1], sort[2], sort[3]];
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