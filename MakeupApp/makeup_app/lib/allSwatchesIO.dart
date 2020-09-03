import 'package:flutter/material.dart' show Widget;
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorProcessing.dart';
import 'globalIO.dart';
import 'types.dart';

Map<int, String> lines;
Map<int, Swatch> swatches;
List<OnVoidAction> onSaveChanged = [];
bool hasSaveChanged = true;
bool isLoading = true;

void listenOnSaveChanged(OnVoidAction listener) {
  onSaveChanged.add(listener);
}

Future<File> getSaveFile() async {
  final String path = await getLocalPath();
  File file = File('$path/assets/save.txt');
  if(!(await file.exists())) {
    file = await file.create(recursive: true);
  }
  return file;
}

void clear() async {
  print('Clearing');
  File file = await getSaveFile();
  await file.delete();
  hasSaveChanged = true;
}

void add(List<Swatch> swatches) async {
  await load();
  List<int> ids = lines.keys.toList();
  int id  = -1;
  if(ids.length > 0) {
    id = ids.reduce(max);
  }
  Map<int, String> info = lines;
  for(int i = 0; i < swatches.length; i++) {
    id++;
    info[id] = await saveSwatch(swatches[i]);
  }
  await save(info);
}

void editId(int i, Swatch swatch) async {
  await load();
  Map<int, String> info = lines;
  info[i] = await saveSwatch(swatch);
  await save(lines);
}

void edit(Swatch old, Swatch swatch) async {
  await editId(find(old), swatch);
}

void removeId(int i) async {
  if(i > 0) {
    await load();
    Map<int, String> info = lines;
    info.remove(i);
    print('removing $i');
    await save(info);
  }
}

void remove(Swatch swatch) async {
  await removeId(find(swatch));
}

int find(Swatch swatch)  {
  if(swatches == null || hasSaveChanged) {
    loadFormatted();
  }
  if(swatches.containsKey(swatch.id)) {
    return swatch.id;
  }
  return -1;
}

List<int> findMany(List<Swatch> currSwatches) {
  List<int> ret = [];
  for(int i = 0; i < currSwatches.length; i++) {
    int id = find(currSwatches[i]);
    if(id != -1) {
      //ignore nonexistent/deleted ones?
      ret.add(id);
    }
  }
  return ret;
}

Swatch get(int i) {
  if(swatches == null || hasSaveChanged) {
    loadFormatted();
  }
  if(swatches.containsKey(i)) {
    return swatches[i];
  }
  return null;
}

List<Swatch> getMany(List<int> ids) {
  List<Swatch> currSwatches = [];
  for(int i = 0; i < ids.length; i++) {
    Swatch swatch = get(ids[i]);
    if(swatch != null) {
      currSwatches.add(swatch);
    }
  }
  return currSwatches;
}

List<List<Swatch>> getMultiple(List<List<int>> ids) {
  List<List<Swatch>> currSwatches = [];
  for(int i = 0; i < ids.length; i++) {
    currSwatches.add(getMany(ids[i]));
  }
  return currSwatches;
}

bool isValid(int i) {
  return swatches.containsKey(i);
}

void save(Map<int, String> info) async {
  File file = await getSaveFile();
  RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
  List<int> keys = info.keys.toList();
  for(int i = 0; i < keys.length; i++) {
    await f.writeString('${keys[i]}|${info[keys[i]]}\n');
  }
  await loadFormatted(override: true, overrideInner: true);
  for(int i = 0; i < onSaveChanged.length; i++) {
    onSaveChanged[i]();
  }
}

Future<Map<int, String>> load({ bool override = false }) async {
  if(lines == null || hasSaveChanged || override) {
    isLoading = true;
    File file = await getSaveFile();
    List<String> fileLines = (await file.readAsString()).split('\n');
    lines = {};
    for(int i = 0; i < fileLines.length; i++) {
      if(fileLines[i] != '') {
        List<String> lineSplit = fileLines[i].split('|');
        if(lineSplit.length > 1) {
          lines[int.parse(lineSplit[0])] = fileLines[i].substring(lineSplit[0].length + 1);
        }
      }
    }
    isLoading = false;
  }
  return lines;
}

Future<List<int>> loadFormatted({ bool override = false, overrideInner = false }) async {
  if(swatches == null || hasSaveChanged || override || overrideInner) {
    isLoading = true;
    swatches = {};
    Map<int, String> info = await load(override: overrideInner);
    print(info.length);
    await info.forEach(
      (key, value) async {
        swatches[key] = await loadSwatch(key, value);
      }
    );
    hasSaveChanged = false;
    isLoading = false;
  }
  List<int> ret = swatches.keys.toList();
  return sort(ret, (a, b) => a.compareTo(b, (swatch) => stepSort(swatch.color, step: 8)));
}

Future<List<int>> sort(List<int> ids, int compare(Swatch a, Swatch b)) async {
  List<Swatch> currSwatches = getMany(ids);
  currSwatches.sort(compare);
  List<int> ret = findMany(currSwatches);
  return ret;
}

Future<Map<Widget, List<int>>> sortMultiple(List<Widget> keys, List<List<int>> values, OnSortSwatch compare) async {
  Map<Widget, List<int>> ret = {};
  for(int i = 0; i < keys.length; i++) {
    ret[keys[i]] = await sort(values[i], (a, b) => a.compareTo(b, (swatch) => compare(swatch, i)));
  }
  return ret;
}