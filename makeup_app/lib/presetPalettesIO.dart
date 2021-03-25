import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorSorting.dart';
import 'Widgets/Swatch.dart';
import 'Widgets/Palette.dart';
import'localizationIO.dart';
import 'globalIO.dart';
import 'globalWidgets.dart' as globalWidgets;
import 'types.dart';

List<DocumentSnapshot> docs;
Map<String, Palette> palettes;
List<OnVoidAction> onSaveChanged = [];
bool hasSaveChanged = true;
bool isLoading = true;

CollectionReference _database;
CollectionReference _databasePending;

void init() {
  _database = FirebaseFirestore.instance.collection('presetPalettes');
  _databasePending = FirebaseFirestore.instance.collection('pendingPresetPalettes');
}

void listenOnSaveChanged(OnVoidAction listener) {
  onSaveChanged.add(listener);
}

Swatch getSwatch(String paletteId, int swatchId) {
  Palette palette = getPalette(paletteId);
  if(palette != null && palette.swatches.length > swatchId) {
    return palette.swatches[swatchId];
  }
  return null;
}

Palette getPalette(String paletteId) {
  if(palettes == null || hasSaveChanged) {
    loadFormatted();
  }
  if(palettes.containsKey(paletteId)) {
    return palettes[paletteId];
  }
  return null;
}

Future<void> save(Palette palette) async {
  //clean name input
  String brand = globalWidgets.toTitleCase(removeAllChars(palette.brand, [r';', r'\\']));
  String name = globalWidgets.toTitleCase(removeAllChars(palette.name, [r';', r'\\']));
  String weight = palette.weight.toStringAsFixed(4);
  String price = palette.price.toStringAsFixed(2);
  String swatchData = '';
  for(int i = 0; i < palette.swatches.length; i++) {
    String save = await savePresetSwatch(palette.swatches[i]);
    swatchData += '$save';
  }
  swatchData = compress(swatchData);
  if(palette.id == '') {
    //adding look for the first time
    palette.id = (await _databasePending.add(
      {
        'brand': brand,
        'name': name,
        'weight': weight,
        'price': price,
        'data': swatchData,
        'status': 1,
      }
    )).id;
  } else {
    //updating palette, assumes not pending
    await _database.doc(palette.id).set(
      {
        'brand': brand,
        'name': name,
        'weight': weight,
        'price': price,
        'data': swatchData,
      }
    );
  }
  //don't need to change save because will be added to admin app first and must be approved
}

Future<List<DocumentSnapshot>> load({ bool override = false }) async {
  if(docs == null || hasSaveChanged || override) {
    docs = (await _database.get()).docs;
  }
  return docs;
}

Future<Map<String, Palette>> loadFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    isLoading = true;
    palettes = {};
    List<DocumentSnapshot> info = await load(override: overrideInner);
    for(int i = 0; i < info.length; i++) {
      Map<String, dynamic> data = info[i].data();
      List<Swatch> swatches = [];
      List<String> swatchLines = decompress(data['data']).split('\n');
      for(int j = 0; j < swatchLines.length; j++) {
        String line = swatchLines[j];
        if(line != '') {
          swatches.add(await loadPresetSwatch(line));
        }
      }
      if(swatches.length == 0) {
        continue;
      }
      Palette palette = Palette(
        id: info[i].id,
        brand: data['brand'] ?? '',
        name: data['name'] ?? '',
        weight: double.parse((data['weight'] ?? 0).toString()),
        price: double.parse((data['price'] ?? 0).toString()),
        swatches: swatches,
      );
      palettes[palette.id] = palette;
    }
    print('${palettes.length} palettes');
    hasSaveChanged = false;
    isLoading = false;
    palettes = await sort();
  }
  return palettes;
}
Future<String> savePresetSwatch(Swatch swatch) async {
  //color
  List<double> colorValues = swatch.color.getValues();
  String color = colorValues[0].toString() + ',' + colorValues[1].toString() + ',' + colorValues[2].toString();
  //finish
  Map<String, String> finishes = { '0': 'finish_matte', '1': 'finish_satin', '2': 'finish_shimmer', '3': 'finish_metallic', '4': 'finish_glitter' };
  String finish = finishes.keys.firstWhere((key) => finishes[key] == swatch.finish, orElse: () => '0');
  //brand
  String brand = removeAllChars(swatch.brand, [r';', r'\\']);
  //palette
  String palette = removeAllChars(swatch.palette, [r';', r'\\']);
  //shade
  String shade = removeAllChars(swatch.shade, [r';', r'\\']);
  //weight
  String weight = swatch.weight.toStringAsFixed(4);
  //price
  String price = swatch.price.toStringAsFixed(2);
  //color name
  String colorName = removeAllChars(swatch.colorName.trim(), [r';', r'\\']);
  if(colorName != '' && !colorName.contains('color_')) {
    //translate color name
    List<String> possibleColorNames = createColorNames().keys.toList();
    for(int i = 0; i < possibleColorNames.length; i++) {
      if(getString(possibleColorNames[i]).toLowerCase() == colorName.toLowerCase()) {
        colorName = possibleColorNames[i];
        break;
      }
    }
  }
  //combined
  return '$color;$finish;$brand;$palette;$shade;$weight;$price;$colorName\n';
}

Future<Swatch> loadPresetSwatch(String line) async {
  if(line == '') {
    return null;
  }
  List<String> lineSplit = line.split(';');
  //color
  List<String> colorValues = lineSplit[0].split(',');
  RGBColor color = RGBColor(double.parse(colorValues[0]), double.parse(colorValues[1]), double.parse(colorValues[2]));
  //finish
  Map<String, String> finishes = { '0': 'finish_matte', '1': 'finish_satin', '2': 'finish_shimmer', '3': 'finish_metallic', '4': 'finish_glitter' };
  String finish = finishes[lineSplit[1]];
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
  //if exists, color name
  String colorName = lineSplit[7];
  //combined
  return Swatch(id: -1, color: color, finish: finish, brand: brand, palette: palette, shade: shade, weight: weight, price: price, colorName: colorName);
}

Future<Map<String, Palette>> sort() async {
  List<Palette> sortedPalettes = palettes.values.toList();
  sortedPalettes.sort(
    (Palette a, Palette b) {
      int brand = a.brand.compareTo(b.brand);
      if(brand == 0) {
        return a.name.compareTo(b.name);
      } else {
        return brand;
      }
    }
  );
  palettes.clear();
  for(int i = 0; i < sortedPalettes.length; i++) {
    palettes[sortedPalettes[i].id] = sortedPalettes[i];
  }
  return palettes;
}

Future<List<Palette>> search(String search) async {
  List<Palette> ret = palettes.values.toList();
  if(search == '' || search == ' ') {
    return ret;
  }
  List<String> searchTerms = search.trim().toLowerCase().replaceAll('‘', '\'').replaceAll('’', '\'').replaceAll('“', '\'').replaceAll('”', '\"').split(' ');
  for(int i = palettes.length - 1; i >= 0; i--) {
    Palette palette = ret[i];
    String possibleTerms = '';

    //add brand to possible search terms, must account for different types of quotes
    String brand = palette.brand.toLowerCase().trimRight().replaceAll('‘', '\'').replaceAll('’', '\'').replaceAll('“', '\'').replaceAll('”', '\"');
    possibleTerms += ' $brand';
    possibleTerms += ' ${brand.replaceAll(RegExp(r'[^\w\s]'), '')}';

    //add name to possible search terms, must account for different types of quotes
    String name = palette.name.toLowerCase().trimRight().replaceAll('‘', '\'').replaceAll('’', '\'').replaceAll('“', '\'').replaceAll('”', '\"');
    possibleTerms += ' $name';
    possibleTerms += ' ${name.replaceAll(RegExp(r'[^\w\s]'), '')}';

    //add brand acronym, either separated by spaces or by capital letters, to possible search terms
    String spaceAcronym = '';
    String capsAcronym = '';
    List<String> brandWords = palette.brand.split(' ');
    for(int j = 0; j < brandWords.length; j++) {
      if(brandWords[j] == '') {
        continue;
      }
      String letter = brandWords[j].substring(0, 1);
      spaceAcronym += letter;
      capsAcronym += letter;
      for(int k = 1; k < brandWords[j].length; k++) {
        letter = brandWords[j].substring(k, k + 1);
        if(letter == letter.toUpperCase()) {
          capsAcronym += letter;
        }
      }
    }
    possibleTerms += ' ${spaceAcronym.toLowerCase()}';
    possibleTerms += ' ${capsAcronym.toLowerCase()}';

    //check if search terms are found in possible search terms
    for(int j = 0; j < searchTerms.length; j++) {
      if(searchTerms[j] == '') {
        continue;
      }
      if(!possibleTerms.contains(' ${searchTerms[j]}')) {
        ret.removeAt(i);
        break;
      }
    }
  }
  return ret;
}