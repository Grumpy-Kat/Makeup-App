import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorObjects.dart';

Future<String> getLocalPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> saveSwatch(Swatch swatch) async {
  //color
  List<double> colorValues = swatch.color.getValues();
  String color = colorValues[0].toString() + ',' + colorValues[1].toString() + ',' + colorValues[2].toString();
  //finish
  String finish = swatch.finish;
  //brand
  String brand = swatch.brand;
  //palette
  String palette = swatch.palette;
  //shade
  String shade = swatch.shade;
  //rating
  String rating = swatch.rating.toString();
  //tags
  String tags = '';
  for(int i = 0; i < swatch.tags.length; i++) {
    tags += swatch.tags[i] + ',';
  }
  //combined
  return '$color;$finish;$brand;$palette;$shade;$rating;$tags\n';
}
Future<Swatch> loadSwatch(int id, String line) async {
  if(line == '') {
    return null;
  }
  List<String> lineSplit = line.split(';');
  //color
  List<String> colorValues = lineSplit[0].split(',');
  RGBColor color = RGBColor(double.parse(colorValues[0]), double.parse(colorValues[1]), double.parse(colorValues[2]));
  //finish
  String finish = lineSplit[1];
  //brand
  String brand = lineSplit[2];
  //palette
  String palette = lineSplit[3];
  //shade
  String shade = lineSplit[4];
  //rating
  int rating = int.parse(lineSplit[5] == '' ? 0 : lineSplit[5]);
  //tags
  List<String> tags = (lineSplit[6] == '' ? [] : lineSplit[6].split(','));
  //combined
  return Swatch(color: color, finish: finish, brand: brand, palette: palette, id: id, shade: shade, rating: rating, tags: tags);
}