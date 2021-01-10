import 'dart:io';
import 'dart:async';
import 'globalIO.dart';
import 'allSwatchesIO.dart' as allSwatches;
import 'globals.dart' as globals;

List<String> lines;
Map<String, List<int>> swatches;
bool hasSaveChanged = true;

void init() {
  allSwatches.listenOnSaveChanged(() {
    loadFormatted(override: true);
  });
}

Future<File> getSaveFileIds() async {
  final String path = await getLocalPath();
  File file = File('$path/assets/savePastIds.txt');
  if(!(await file.exists())) {
    file = await file.create(recursive: true);
  }
  return file;
}

Future<File> getSaveFile(int id) async {
  final String path = await getLocalPath();
  File file = File('$path/assets/$id.txt');
  if(!(await file.exists())) {
    file = await file.create(recursive: true);
  }
  return file;
}

void clearIds() async {
  File file = await getSaveFileIds();
  await file.writeAsString('');
  hasSaveChanged = true;
}

void clear(int id) async {
  File file = await getSaveFile(id);
  await file.writeAsString('');
  hasSaveChanged = true;
}

Future<int> save(int id, String name, List<int> info) async  {
  print('save $id');
  hasSaveChanged = true;
  //add to master list
  if(id == -1) {
    //creating new saved look
    File fileAll = await getSaveFileIds();
    List<String> ids = await loadIds(fileAll: fileAll);
    int newId;
    if(ids.length == 0 || ids.length == 1) {
      //first id
      newId = 0;
    } else {
      newId = int.parse(ids[ids.length - 1] == '' ? '0' : ids[ids.length - 1]) + 1;
    }
    ids.add(newId.toString());
    String string = '';
    for(int i = 0; i < ids.length; i++) {
      string += '${ids[i]}\n';
    }
    RandomAccessFile f = await fileAll.open(mode: FileMode.writeOnly);
    String compressed = compress(string);
    await f.writeString(compressed);
    id = newId;
  }
  //save individual look
  String string = '';
  name = removeAllChars(name, [r'\\']);
  if(name == '') {
    name = 'Look';
  }
  string += '$name\n';
  for(int i = 0; i < info.length; i++) {
    string += '${info[i]}\n';
  }
  File file = await getSaveFile(id);
  RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
  String compressed = compress(string);
  await f.writeString(compressed);
  return id;
}

Future<List<String>> loadIds({ File fileAll = null }) async {
  fileAll = await getSaveFileIds();
  List<String> ids = decompress(await fileAll.readAsString()).split('\n');
  ids = ids.toSet().toList();
  return ids;
}

Future<List<String>> load({ bool override = false }) async {
  if(lines == null || hasSaveChanged || override) {
    List<String> ids = await loadIds();
    lines = [];
    for(int i = 0; i < ids.length; i++) {
      if(ids[i] == '') {
        continue;
      }
      File file = await getSaveFile(int.parse(ids[i]));
      List<String> fileLines = decompress(await file.readAsString()).split('\n');
      for(int j = 0; j < fileLines.length; j++) {
        String line = fileLines[j];
        if(j == 0) {
          lines.add('${ids[i]}|$line');
        } else {
          lines.add(line);
        }
      }
      lines.add('');
    }
  }
  return lines;
}

Future<Map<String, List<int>>> loadFormatted({ bool override = false, overrideInner = false }) async {
  if(swatches == null || hasSaveChanged || override || overrideInner) {
    swatches = {};
    List<int> swatchList = [];
    String lastLabel = '';
    List<String> info = await load(override: overrideInner);
    for(int i = 0; i < info.length - 1; i++) {
      if(info[i] == "") {
        if(swatchList.length > 0) {
          //contains swatches
          swatchList = await allSwatches.sort(swatchList, (a, b) => a.compareTo(b, (swatch) => globals.defaultSortOptions([allSwatches.getMany(swatchList)])[globals.sort](swatch, 0)));
          swatches[lastLabel] = swatchList;
        }
        swatchList = [];
        continue;
      }
      if(info[i].split('|').length > 1) {
        lastLabel = info[i];
        continue;
      }
      int id = int.parse(info[i]);
      if(allSwatches.isValid(id)) {
        swatchList.add(id);
      }
    }
    print('${swatches.length} looks');
    hasSaveChanged = false;
  }
  return swatches;
}