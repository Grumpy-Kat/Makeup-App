import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import '../Widgets/Swatch.dart';

Map<String, RGBColor> colorWheel;
Map<String, List<String>> similarColorNames;
Map<String, List<String>> oppositeColorNames;

Map<String, RGBColor> createColorWheel() {
  if(colorWheel == null) {
    colorWheel = Map<String, RGBColor>();
    colorWheel['pastel red'] = RGBColor(1, 0.95, 0.95);
    colorWheel['nude'] = RGBColor(0.920, 0.804, 0.745);
    colorWheel['light red'] = RGBColor(1, 0.8, 0.8);
    colorWheel['red'] = RGBColor(0.9, 0.3, 0.3);
    colorWheel['dark red'] = RGBColor(0.2, 0, 0);
    colorWheel['burgundy'] = RGBColor(0.322, 0, 0.078);
    colorWheel['pastel orange'] = RGBColor(1, 0.95, 0.85);
    colorWheel['peach'] = RGBColor(1, 0.882, 0.741);
    colorWheel['light orange'] = RGBColor(1, 0.8, 0.6);
    colorWheel['orange'] = RGBColor(1, 0.5, 0.1);
    colorWheel['dark orange'] = RGBColor(0.2, 0.1, 0);
    colorWheel['light brown'] = RGBColor(0.851, 0.654, 0.494);
    colorWheel['beige'] = RGBColor(0.761, 0.551, 0.471);
    colorWheel['taupe'] = RGBColor(0.529, 0.475, 0.427);
    colorWheel['tan'] = RGBColor(0.859, 0.600, 0.318);
    colorWheel['brown'] = RGBColor(0.565, 0.350, 0.212);
    colorWheel['rust'] = RGBColor(0.600, 0.220, 0.114);
    colorWheel['dark beige'] = RGBColor(0.388, 0.322, 0.240);
    colorWheel['dark brown'] = RGBColor(0.169, 0.114, 0.063);
    colorWheel['chocolate'] = RGBColor(0.251, 0.102, 0.039);
    colorWheel['pastel yellow'] = RGBColor(1, 1, 0.9);
    colorWheel['cream'] = RGBColor(1, 0.959, 0.851);
    colorWheel['light yellow'] = RGBColor(1, 1, 0.6);
    colorWheel['yellow'] = RGBColor(0.9, 0.9, 0.1);
    colorWheel['light chartreuse'] = RGBColor(0.9, 1, 0.8);
    colorWheel['chartreuse'] = RGBColor(0.5, 0.9, 0.1);
    colorWheel['dark chartreuse'] = RGBColor(0.1, 0.2, 0);
    colorWheel['pastel green'] = RGBColor(0.95, 1, 0.95);
    colorWheel['light green'] = RGBColor(0.8, 1, 0.8);
    colorWheel['green'] = RGBColor(0.1, 0.9, 0.1);
    colorWheel['dark green'] = RGBColor(0, 0.2, 0);
    colorWheel['pastel mint'] = RGBColor(0.95, 1, 0.95);
    colorWheel['mint'] = RGBColor(0.8, 1, 0.9);
    colorWheel['aquamarine'] = RGBColor(0.2, 0.9, 0.5);
    colorWheel['dark aquamarine'] = RGBColor(0, 0.2, 0.1);
    colorWheel['pastel turquoise'] = RGBColor(0.9, 1, 1);
    colorWheel['light turquoise'] = RGBColor(0.8, 1, 1);
    colorWheel['turquoise'] = RGBColor(0.4, 0.9, 0.9);
    colorWheel['dark turquoise'] = RGBColor(0, 0.2, 0.2);
    colorWheel['light sky blue'] = RGBColor(0.8, 0.9, 1);
    colorWheel['sky blue'] = RGBColor(0.2, 0.5, 0.9);
    colorWheel['dark sky blue'] = RGBColor(0, 0.1, 0.2);
    colorWheel['pastel blue'] = RGBColor(0.9, 0.95, 1);
    colorWheel['light blue'] = RGBColor(0.8, 0.8, 1);
    colorWheel['blue'] = RGBColor(0.1, 0.1, 0.9);
    colorWheel['dark blue'] = RGBColor(0, 0, 0.2);
    colorWheel['pastel lavender'] = RGBColor(0.95, 0.9, 1);
    colorWheel['lavender'] = RGBColor(0.9, 0.8, 1);
    colorWheel['indigo'] = RGBColor(0.5, 0, 1);
    colorWheel['dark indigo'] = RGBColor(0.1, 0, 0.2);
    colorWheel['light purple'] = RGBColor(1, 0.8, 1);
    colorWheel['purple'] = RGBColor(0.9, 0.1, 0.9);
    colorWheel['dark purple'] = RGBColor(0.2, 0, 0.2);
    colorWheel['mauve'] = RGBColor(0.8, 0.6, 0.7);
    colorWheel['violet'] = RGBColor(0.9, 0.3, 0.9);
    colorWheel['dark violet'] = RGBColor(0.15, 0, 0.15);
    colorWheel['pastel pink'] = RGBColor(1, 0.9, 0.95);
    colorWheel['light pink'] = RGBColor(1, 0.8, 0.9);
    colorWheel['pink'] = RGBColor(0.9, 0.1, 0.5);
    colorWheel['dark pink'] = RGBColor(0.2, 0, 0.1);
    colorWheel['white'] = RGBColor(1, 1, 1);
    colorWheel['light gray'] = RGBColor(0.25, 0.25, 0.25);
    colorWheel['gray'] = RGBColor(0.5, 0.5, 0.5);
    colorWheel['dark gray'] = RGBColor(0.75, 0.75, 0.75);
    colorWheel['dark taupe'] = RGBColor(0.271, 0.247, 0.227);
    colorWheel['black'] = RGBColor(0, 0, 0);
  }
  return colorWheel;
}

Map<String, List<String>> createSimilarColorNames() {
  if(similarColorNames == null) {
    similarColorNames = Map<String, List<String>>();
    similarColorNames['white'] = ['light gray', 'gray', 'dark gray', 'black', 'cream', 'pastel red', 'pastel orange', 'pastel yellow', 'pastel green', 'pastel mint', 'pastel turquoise', 'pastel blue', 'pastel lavender', 'pastel pink'];
    similarColorNames['light gray'] = ['white', 'gray', 'dark gray', 'black'];
    similarColorNames['gray'] = ['white', 'light gray', 'dark gray', 'black', 'taupe'];
    similarColorNames['dark gray'] = ['white', 'light gray', 'gray', 'black', 'dark taupe'];
    similarColorNames['black'] = ['white', 'light gray', 'gray', 'dark gray'];
    similarColorNames['light brown'] = ['brown', 'dark brown', 'beige', 'chocolate', 'light orange', 'orange', 'light red', 'red'];
    similarColorNames['brown'] = ['light brown', 'dark brown', 'beige', 'dark beige', 'chocolate', 'light orange', 'orange', 'dark orange', 'light red', 'red', 'dark red', 'burgundy'];
    similarColorNames['dark brown'] = ['light brown', 'brown', 'beige', 'dark beige', 'chocolate', 'light orange', 'orange', 'dark orange', 'light red', 'red', 'dark red', 'burgundy'];
    similarColorNames['beige'] = ['dark beige', 'light brown', 'brown', 'dark brown', 'light orange', 'orange', 'dark orange'];
    similarColorNames['dark beige'] = ['beige', 'brown', 'dark brown', 'light orange', 'orange', 'dark orange'];
    similarColorNames['taupe'] = ['dark taupe', 'dark brown', 'white', 'light gray', 'black'];
    similarColorNames['dark taupe'] = ['taupe', 'dark brown', 'white', 'light gray', 'black'];
    similarColorNames['nude'] = ['beige', 'dark beige', 'chocolate', 'light brown', 'dark brown', 'light orange', 'orange', 'dark orange'];
    similarColorNames['cream'] = ['white', 'pastel yellow', 'yellow', 'taupe', 'dark taupe'];
    similarColorNames['peach'] = ['light brown', 'brown', 'dark brown', 'chocolate', 'tan', 'light orange', 'orange', 'dark orange'];
    similarColorNames['tan'] = ['light brown', 'brown', 'dark brown', 'peach', 'light orange', 'orange', 'dark orange', 'yellow'];
    similarColorNames['rust'] = ['light brown', 'brown', 'dark brown', 'beige', 'dark beige', 'chocolate', 'light red', 'red'];
    similarColorNames['chocolate'] = ['nude', 'light brown', 'brown', 'dark brown', 'beige', 'dark beige', 'rust', 'red', 'dark red', 'burgundy'];
    similarColorNames['pastel red'] = ['white', 'light red', 'red', 'dark red', 'burgundy', 'pastel orange', 'pastel pink', 'pastel lavender'];
    similarColorNames['light red'] = ['pastel red', 'red', 'dark red', 'burgundy', 'light orange', 'light pink', 'mauve'];
    similarColorNames['red'] = ['pastel red', 'light red', 'dark red', 'burgundy', 'orange', 'pink', 'violet'];
    similarColorNames['dark red'] = ['pastel red', 'light red', 'red', 'burgundy', 'dark orange', 'dark pink', 'dark violet'];
    similarColorNames['burgundy'] = ['pastel red', 'light red', 'red', 'dark red', 'dark orange', 'dark pink', 'dark violet', 'dark purple'];
    similarColorNames['pastel orange'] = ['white', 'light orange', 'orange', 'dark orange', 'pastel red', 'pastel yellow'];
    similarColorNames['light orange'] = ['pastel orange', 'orange', 'dark orange', 'light red', 'light yellow'];
    similarColorNames['orange'] = ['pastel orange', 'light orange', 'dark orange', 'red', 'yellow'];
    similarColorNames['dark orange'] = ['pastel orange', 'light orange', 'orange', 'dark red', 'burgundy'];
    similarColorNames['pastel yellow'] = ['white', 'light yellow', 'yellow', 'pastel green', 'pastel mint', 'pastel orange'];
    similarColorNames['light yellow'] = ['pastel yellow', 'yellow', 'light chartreuse', 'light green', 'light orange'];
    similarColorNames['yellow'] = ['pastel yellow', 'light yellow', 'chartreuse', 'green', 'orange'];
    similarColorNames['light chartreuse'] = ['pastel green', 'pastel yellow', 'chartreuse', 'dark chartreuse', 'light aquamarine', 'light green', 'light yellow'];
    similarColorNames['chartreuse'] = ['pastel green', 'pastel yellow', 'light chartreuse', 'dark chartreuse', 'aquamarine', 'green', 'yellow'];
    similarColorNames['dark chartreuse'] = ['pastel green', 'pastel yellow', 'light chartreuse', 'chartreuse', 'dark aquamarine', 'dark green', 'dark yellow'];
    similarColorNames['pastel green'] = ['white', 'light green', 'green', 'dark green', 'pastel mint', 'pastel turquoise', 'pastel yellow'];
    similarColorNames['light green'] = ['pastel green', 'green', 'dark green', 'mint', 'light turquoise', 'light chartreuse', 'light yellow'];
    similarColorNames['green'] = ['pastel green', 'light green', 'dark green', 'aquamarine', 'turquoise', 'chartreuse', 'yellow'];
    similarColorNames['dark green'] = ['pastel green', 'light green', 'green', 'dark aquamarine', 'dark turquoise', 'dark chartreuse'];
    similarColorNames['pastel mint'] = ['white', 'mint', 'aquamarine', 'aquamarine', 'pastel blue', 'pastel turquoise', 'pastel green'];
    similarColorNames['mint'] = ['pastel mint', 'aquamarine', 'dark aquamarine', 'light sky blue', 'light turquoise', 'light green'];
    similarColorNames['aquamarine'] = ['pastel mint', 'mint', 'dark aquamarine', 'sky blue', 'turquoise', 'green'];
    similarColorNames['dark aquamarine'] = ['pastel mint', 'mint', 'aquamarine', 'dark sky blue', 'dark turquoise', 'dark green'];
    similarColorNames['pastel turquoise'] = ['white', 'light turquoise', 'turquoise', 'dark turquoise', 'pastel blue', 'pastel green', 'pastel mint'];
    similarColorNames['light turquoise'] = ['pastel turquoise', 'turquoise', 'dark turquoise', 'light blue', 'light sky blue', 'light green', 'mint'];
    similarColorNames['turquoise'] = ['pastel turquoise', 'light turquoise', 'dark turquoise', 'blue', 'sky blue', 'green', 'aquamarine'];
    similarColorNames['dark turquoise'] = ['pastel turquoise', 'light turquoise', 'turquoise', 'dark blue', 'dark sky blue', 'dark green', 'dark aquamarine'];
    similarColorNames['light sky blue'] = ['pastel blue', 'sky blue', 'dark sky blue', 'light blue', 'lavender', 'light turquoise', 'mint'];
    similarColorNames['sky blue'] = ['pastel blue', 'light sky blue', 'dark sky blue', 'blue', 'indigo', 'turquoise', 'aquamarine'];
    similarColorNames['dark sky blue'] = ['pastel blue', 'light sky blue', 'sky blue', 'dark blue', 'dark indigo', 'dark turquoise', 'dark aquamarine'];
    similarColorNames['pastel blue'] = ['white', 'light blue', 'blue', 'dark blue', 'pastel lavender', 'pastel turquoise'];
    similarColorNames['light blue'] = ['pastel blue', 'blue', 'dark blue', 'light purple', 'lavender', 'turquoise', 'sky blue'];
    similarColorNames['blue'] = ['pastel blue', 'light blue', 'dark blue', 'purple', 'indigo', 'turquoise', 'sky blue'];
    similarColorNames['dark blue'] = ['pastel blue', 'light blue', 'blue', 'dark purple', 'dark indigo', 'dark turquoise', 'dark sky blue'];
    similarColorNames['pastel lavender'] = ['white', 'lavender', 'indigo', 'dark indigo', 'pastel pink', 'pastel blue'];
    similarColorNames['lavender'] = ['pastel lavender', 'indigo', 'dark indigo', 'light purple', 'light violet', 'light blue', 'light sky blue'];
    similarColorNames['indigo'] = ['pastel lavender', 'lavender', 'dark indigo', 'purple', 'violet', 'blue', 'sky blue'];
    similarColorNames['dark indigo'] = ['pastel lavender', 'lavender', 'indigo', 'dark purple', 'dark violet', 'dark blue', 'dark sky blue'];
    similarColorNames['light purple'] = ['pastel lavender', 'purple', 'dark purple', 'light pink', 'mauve', 'lavender', 'light blue'];
    similarColorNames['purple'] = ['pastel lavender', 'light purple', 'dark purple', 'pink', 'violet', 'indigo', 'blue'];
    similarColorNames['dark purple'] = ['pastel lavender', 'light purple', 'purple', 'dark pink', 'dark violet', 'dark indigo', 'dark blue'];
    similarColorNames['mauve'] = ['pastel lavender', 'violet', 'dark violet', 'light pink', 'light red', 'light purple', 'lavender'];
    similarColorNames['violet'] = ['pastel lavender', 'mauve', 'dark violet', 'pink', 'red', 'purple', 'indigo'];
    similarColorNames['dark violet'] = ['pastel lavender', 'mauve', 'violet', 'dark pink', 'dark red', 'burgundy', 'dark purple', 'dark indigo'];
    similarColorNames['pastel pink'] = ['white', 'light pink', 'pink', 'dark pink', 'pastel red', 'pastel lavender'];
    similarColorNames['light pink'] = ['pastel pink', 'pink', 'dark pink', 'light red', 'mauve'];
    similarColorNames['pink'] = ['pastel pink', 'light pink', 'dark pink', 'red', 'violet'];
    similarColorNames['dark pink'] = ['pastel pink', 'light pink', 'pink', 'dark red', 'burgundy', 'dark violet'];
  }
  return similarColorNames;
}

Map<String, List<String>> createOppositeColorNames() {
  if(oppositeColorNames == null) {
    oppositeColorNames = Map<String, List<String>>();
    oppositeColorNames['white'] = [];
    oppositeColorNames['light gray'] = [];
    oppositeColorNames['gray'] = [];
    oppositeColorNames['dark gray'] = [];
    oppositeColorNames['black'] = ['nude', 'cream', 'pastel red', 'pastel orange', 'pastel yellow', 'pastel green', 'pastel mint', 'pastel turquoise', 'pastel blue', 'pastel lavender', 'pastel pink'];
    oppositeColorNames['light brown'] = [];
    oppositeColorNames['brown'] = [];
    oppositeColorNames['dark brown'] = [];
    oppositeColorNames['beige'] = [];
    oppositeColorNames['dark beige'] = [];
    oppositeColorNames['taupe'] = [];
    oppositeColorNames['dark taupe'] = [];
    oppositeColorNames['nude'] = [];
    oppositeColorNames['cream'] = [];
    oppositeColorNames['peach'] = [];
    oppositeColorNames['tan'] = [];
    oppositeColorNames['rust'] = [];
    oppositeColorNames['chocolate'] = [];
    oppositeColorNames['pastel red'] = ['pastel blue', 'pastel turquoise', 'pastel mint', 'pastel green', 'black'];
    oppositeColorNames['light red'] = ['light blue', 'light sky blue', 'light turquoise', 'mint', 'light green', 'light chartreuse'];
    oppositeColorNames['red'] = ['blue', 'sky blue', 'turquoise', 'aquamarine', 'green', 'chartreuse'];
    oppositeColorNames['dark red'] = ['dark blue', 'dark sky blue', 'dark turquoise', 'dark aquamarine', 'dark green', 'dark chartreuse'];
    oppositeColorNames['burgundy'] = ['dark blue', 'dark sky blue', 'dark turquoise', 'dark aquamarine', 'dark green', 'dark chartreuse'];
    oppositeColorNames['pastel orange'] = ['pastel lavender', 'pastel blue', 'pastel turquoise', 'pastel mint', 'pastel green', 'black'];
    oppositeColorNames['light orange'] = ['light purple', 'lavender', 'light blue', 'light sky blue', 'light turquoise', 'mint', 'light green'];
    oppositeColorNames['orange'] = ['purple', 'indigo', 'blue', 'sky blue', 'turquoise', 'aquamarine', 'green'];
    oppositeColorNames['dark orange'] = ['dark purple', 'dark indigo', 'dark blue', 'dark sky blue', 'dark turquoise', 'dark aquamarine', 'dark green'];
    oppositeColorNames['pastel yellow'] = ['pastel pink', 'pastel lavender', 'pastel blue', 'black'];
    oppositeColorNames['light yellow'] = ['light pink', 'mauve', 'light purple', 'lavender', 'light blue', 'light sky blue'];
    oppositeColorNames['yellow'] = ['pink', 'dark pink', 'violet', 'dark violet', 'purple', 'dark purple', 'indigo', 'dark indigo', 'blue', 'dark blue', 'sky blue', 'dark sky blue'];
    oppositeColorNames['light chartreuse'] = ['light red', 'light pink', 'mauve', 'purple', 'indigo'];
    oppositeColorNames['chartreuse'] = ['red', 'pink', 'violet', 'purple', 'indigo'];
    oppositeColorNames['dark chartreuse'] = ['dark red', 'burgundy', 'dark pink', 'dark violet', 'dark purple', 'dark indigo'];
    oppositeColorNames['pastel green'] = ['pastel orange', 'pastel red', 'pastel pink', 'pastel lavender', 'black'];
    oppositeColorNames['light green'] = ['light orange', 'light red', 'light pink', 'mauve', 'light purple'];
    oppositeColorNames['green'] = ['orange', 'red', 'pink', 'violet', 'purple'];
    oppositeColorNames['dark green'] = ['dark orange', 'dark red', 'burgundy', 'dark pink', 'dark violet', 'dark purple'];
    oppositeColorNames['pastel mint'] = ['pastel lavender', 'pastel pink', 'pastel red', 'pastel orange', 'black'];
    oppositeColorNames['mint'] = ['light purple', 'mauve', 'light pink', 'light red', 'light orange'];
    oppositeColorNames['aquamarine'] = ['purple', 'violet', 'pink', 'red', 'orange'];
    oppositeColorNames['dark aquamarine'] = ['dark purple', 'dark violet', 'dark pink', 'dark red', 'burgundy', 'dark orange'];
    oppositeColorNames['pastel turquoise'] = ['pastel pink', 'pastel red', 'pastel orange', 'black'];
    oppositeColorNames['light turquoise'] = ['light pink', 'light red', 'light orange'];
    oppositeColorNames['turquoise'] = ['pink', 'red', 'orange'];
    oppositeColorNames['dark turquoise'] = ['dark pink', 'dark red', 'burgundy', 'dark orange'];
    oppositeColorNames['light sky blue'] = ['light pink', 'light red', 'light orange', 'light yellow'];
    oppositeColorNames['sky blue'] = ['pink', 'red', 'orange', 'yellow'];
    oppositeColorNames['dark sky blue'] = ['dark pink', 'dark red', 'burgundy', 'dark orange', 'yellow'];
    oppositeColorNames['pastel blue'] = ['pastel pink', 'pastel red', 'pastel orange', 'pastel yellow', 'black'];
    oppositeColorNames['light blue'] = ['light pink', 'light red', 'light orange', 'light yellow'];
    oppositeColorNames['blue'] = ['pink', 'red', 'orange', 'yellow'];
    oppositeColorNames['dark blue'] = ['dark pink', 'dark red', 'burgundy', 'dark orange', 'yellow'];
    oppositeColorNames['pastel lavender'] = [ 'pastel orange', 'pastel yellow', 'pastel green', 'pastel mint', 'black'];
    oppositeColorNames['lavender'] = ['light orange', 'light yellow', 'light chartreuse'];
    oppositeColorNames['indigo'] = ['orange', 'yellow', 'chartreuse'];
    oppositeColorNames['dark indigo'] = ['dark orange', 'yellow', 'dark chartreuse'];
    oppositeColorNames['light purple'] = ['light orange', 'light yellow', 'light chartreuse', 'light green', 'mint'];
    oppositeColorNames['purple'] = ['orange', 'yellow', 'chartreuse', 'green', 'aquamarine'];
    oppositeColorNames['dark purple'] = ['dark orange', 'yellow', 'dark chartreuse', 'dark green', 'dark aquamarine'];
    oppositeColorNames['mauve'] = ['light yellow', 'light chartreuse', 'light green', 'mint'];
    oppositeColorNames['violet'] = ['yellow', 'chartreuse', 'green', 'aquamarine'];
    oppositeColorNames['dark violet'] = ['yellow', 'dark chartreuse', 'dark green', 'dark aquamarine'];
    oppositeColorNames['pastel pink'] = ['pastel blue', 'pastel green', 'pastel green', 'pastel mint', 'pastel turquoise', 'pastel blue' 'black'];
    oppositeColorNames['light pink'] = ['light yellow', 'light chartreuse', 'light green', 'mint', 'light turquoise', 'light blue'];
    oppositeColorNames['pink'] = ['yellow', 'chartreuse', 'green', 'aquamarine', 'turquoise', 'blue'];
    oppositeColorNames['dark pink'] = ['yellow', 'dark chartreuse', 'dark green', 'dark aquamarine', 'dark turquoise', 'dark blue'];
  }
  return oppositeColorNames;
}

List<double> stepSort(RGBColor rgb, { int step = 1 }) {
  List<double> val = rgb.getValues();
  double threshold = 0.085;
  bool isGray = ((val[0] - val[1]).abs() < threshold && (val[0] - val[2]).abs() < threshold && (val[1] - val[2]).abs() < threshold);
  double lum = 0.241 * val[0] + 0.691 * val[1] + 0.068 * val[2];
  List<double> hsvVal = RGBtoHSV(rgb).getValues();
  double h2 = (hsvVal[0] * step).roundToDouble();
  double v2 = (hsvVal[2] * step).roundToDouble();
  double lum2 = (lum * step).roundToDouble();
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
  if(isGray) {
    return [1, step - v2, step - lum2, h2];
  }
  return [0, h2, lum2, v2];
}

List<double> colorWheelSort(RGBColor rgb, { int step = 1 }) {
  List<double> sort = stepSort(rgb, step: step);
  Map<String, RGBColor> colorWheel = createColorWheel();
  double minDist = 1000;
  int minIndex = 0;
  LabColor color0 = RGBtoLab(rgb);
  List<String> keys = colorWheel.keys.toList();
  for(int i = 0; i < keys.length; i++) {
    String color = keys[i];
    LabColor color1 = RGBtoLab(colorWheel[color]);
    double dist = deltaECie2000(color0, color1);
    if(dist < minDist) {
      minDist = dist;
      minIndex = i;
    }
  }
  //colorName: 0 - colorWheel.length
  //h: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
  if(sort[0] == 1) {
    return [minIndex.toDouble(), sort[1], sort[2], sort[3]];
  }
  double h = sort[1];
  if(h < step / 2) {
    h = step - h;
  }
  return [minIndex.toDouble(), h, sort[2], sort[3]];
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

List<double> finishSort(Swatch swatch, { int step = 1, String firstFinish = '' }) {
  List<double> sort = stepSort(swatch.color, step: step);
  double finish = 10;
  switch(swatch.finish.toLowerCase()) {
    case 'matte':
      finish = 1;
      break;
    case 'satin':
      finish = 2;
      break;
    case 'shimmer':
      finish = 3;
      break;
    case 'metallic':
      finish = 4;
      break;
    case 'glitter':
      finish = 5;
      break;
    default:
      finish = 10;
      break;
  }
  if(swatch.finish.toLowerCase() == firstFinish) {
    finish = 0;
  }
  //finish: 0 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
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
  //lum2: 0 - step
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
  //lum2: 0 - step
  if(sort[0] == 1) {
    return [v, s, sort[2], sort[3]];
  }
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