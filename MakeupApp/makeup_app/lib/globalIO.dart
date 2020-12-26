import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorObjects.dart';

Map<String, String> _finishes = { '0': 'finish_matte', '1': 'finish_satin', '2': 'finish_shimmer', '3': 'finish_metallic', '4': 'finish_glitter' };

Future<String> getLocalPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String compress(String string) {
  if(string == '') {
    return '';
  }
  List<int> bytes = utf8.encode(string);
  String compressed = base64.encode(ZLibCodec().encode(bytes));
  return compressed;
}

String decompress(String compressed) {
  if(compressed == '') {
    return '';
  }
  List<int> bytes = base64.decode(compressed);
  String string  = utf8.decode(ZLibDecoder().decodeBytes(bytes));
  return string;
}

Future<String> saveSwatch(Swatch swatch) async {
  //color
  List<double> colorValues = swatch.color.getValues();
  String color = colorValues[0].toString() + ',' + colorValues[1].toString() + ',' + colorValues[2].toString();
  //finish
  String finish = _finishes.keys.firstWhere((key) => _finishes[key] == swatch.finish, orElse: () => '0');
  //brand
  String brand = swatch.brand;
  //palette
  String palette = swatch.palette;
  //shade
  String shade = swatch.shade;
  //weight
  String weight = swatch.weight.toString();
  //price
  String price = swatch.price.toString();
  //rating
  String rating = swatch.rating.toString();
  //tags
  String tags = '';
  if(swatch.tags != null) {
    for (int i = 0; i < swatch.tags.length; i++) {
      tags += swatch.tags[i] + ',';
    }
  }
  //combined
  return '$color;$finish;$brand;$palette;$shade;$weight;$price;$rating;$tags\n';
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
  String finish = _finishes[lineSplit[1]];
  //brand
  String brand = lineSplit[2];
  //palette
  String palette = lineSplit[3];
  //shade
  String shade = lineSplit[4];
  //weight
  double weight = double.parse(lineSplit[5]);
  //price
  double price = double.parse(lineSplit[6]);
  //rating
  int rating = int.parse(lineSplit[7] == '' ? 0 : lineSplit[7]);
  //tags
  List<String> tags = (lineSplit[8] == '' ? [] : lineSplit[8].split(','));
  //combined
  return Swatch(color: color, finish: finish, brand: brand, palette: palette, id: id, shade: shade, weight: weight, price: price, rating: rating, tags: tags);
}