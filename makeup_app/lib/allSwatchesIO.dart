import 'package:flutter/material.dart' show Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'Widgets/Swatch.dart';
import 'Widgets/Filter.dart';
import 'globalIO.dart';
import 'globals.dart' as globals;
import 'types.dart';

Map<int, String> lines;
Map<int, Swatch> swatches;
List<OnVoidAction> onSaveChanged = [];
bool hasSaveChanged = true;
bool isLoading = true;

CollectionReference _database;

void init() {
  _database = FirebaseFirestore.instance.collection('swatches');
}

void listenOnSaveChanged(OnVoidAction listener) {
  onSaveChanged.add(listener);
}

void clear() async {
  print('Clearing');
  await _database.doc(globals.userID).set(
    {
      'data': '',
    }
  );
  hasSaveChanged = true;
}

Future<List<int>> add(List<Swatch> swatches) async {
  await load();
  List<int> ids = lines.keys.toList();
  int id  = 0;
  if(ids.length > 0) {
    id = ids.reduce(max);
  }
  Map<int, String> info = lines;
  List<int> newIds = [];
  for(int i = 0; i < swatches.length; i++) {
    id++;
    newIds.add(id);
    info[id] = await saveSwatch(swatches[i]);
  }
  await save(info);
  return newIds;
}

void editId(int i, Swatch swatch) async {
  await load();
  Map<int, String> info = lines;
  info[i] = await saveSwatch(swatch);
  await save(lines);
}

void editIds(Map<int, Swatch> idsSwatchesMap) async {
  await load();
  Map<int, String> info = lines;
  List<int> ids = idsSwatchesMap.keys.toList();
  List<Swatch> swatches = idsSwatchesMap.values.toList();
  for(int i = 0; i < ids.length; i++) {
    info[ids[i]] = await saveSwatch(swatches[i]);
  }
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

void removeIDsMany(List<int> ids) async {
  for (int i = ids.length - 1; i >= 0; i--) {
    await removeId(ids[i]);
  }
}

void remove(Swatch swatch) async {
  await removeId(find(swatch));
}

void removeMany(List<Swatch> swatches) async {
  for (int i = swatches.length - 1; i >= 0; i--) {
    await removeId(find(swatches[i]));
  }
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

void save(Map<int, String> info, { int tries = 0 }) async {
  List<int> keys = info.keys.toList();
  String string = '';
  for(int i = 0; i < keys.length; i++) {
    string += '${keys[i]}|${info[keys[i]]}\n';
  }
  String compressed = compress(string);
  try {
    base64.normalize(compressed);
    await _database.doc(globals.userID).set(
        {
          'data': compressed,
        }
    );
    await loadFormatted(override: true, overrideInner: true);
    for(int i = 0; i < onSaveChanged.length; i++) {
      onSaveChanged[i]();
    }
  } catch(e) {
    //just ignore it, which effectively reverts to the previous save?
    //helps prevent save from being corrupted, but might miss some data
    print(e);
    if(tries <= 5) {
      await save(info, tries: tries + 1);
    }
  }
}

Future<Map<int, String>> load({ bool override = false }) async {
  if(lines == null || hasSaveChanged || override) {
    isLoading = true;
    DocumentSnapshot docSnapshot = await _database.doc(globals.userID).get();
    List<String> fileLines = [];
    if(docSnapshot != null) {
      fileLines = decompress(docSnapshot.get('data') ?? '').split('\n');
    }
    lines = {};
    for(int i = 0; i < fileLines.length; i++) {
      String line = fileLines[i];
      if(line != '') {
        List<String> lineSplit = line.split('|');
        if(lineSplit.length > 1) {
          lines[int.parse(lineSplit[0])] = line.substring(lineSplit[0].length + 1);
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
    print('${info.length} swatches');
    await info.forEach(
      (key, value) async {
        swatches[key] = await loadSwatch(key, value);
      }
    );
    hasSaveChanged = false;
    isLoading = false;
  }
  List<int> ret = swatches.keys.toList();
  return sort(ret, (a, b) => a.compareTo(b, (swatch) => globals.defaultSortOptions([swatches.values.toList()])[globals.sort](swatch, 0)));
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

Future<List<int>> filter(List<int> ids, List<Filter> filters) async {
  List<int> ret = ids.toList();
  for (int i = ids.length - 1; i >= 0; i--) {
    Map<String, dynamic> swatchAttributes = swatches[ids[i]].getMap();
    for (int j = 0; j < filters.length; j++) {
      String attribute = filters[j].attribute;
      if(swatchAttributes.containsKey(attribute)) {
        dynamic value = swatchAttributes[attribute];
        if(value is String) {
          //make all strings lowercase to avoid issues
          value = (value as String).toLowerCase();
          filters[j].threshold = (filters[j].threshold as String).toLowerCase();
        }
        if(!filters[j].contains(value)) {
          ret.removeAt(i);
          break;
        }
      }
    }
  }
  return ret;
}

Future<Map<Widget, List<int>>> filterMultiple(List<Widget> keys, List<List<int>> values, List<Filter> filters) async {
  Map<Widget, List<int>> ret = {};
  for(int i = 0; i < keys.length; i++) {
    ret[keys[i]] = await filter(values[i], filters);
  }
  return ret;
}