import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:async';
import 'globalIO.dart';
import 'globals.dart' as globals;

CollectionReference _database;

void init() {
  _database = FirebaseFirestore.instance.collection('users');
}

Future<File> getSaveFile() async {
  final String path = await getLocalPath();
  File file = File('$path/assets/settings.txt');
  if(!(await file.exists())) {
    file = await file.create(recursive: true);
  }
  return file;
}

void clear() async {
  print('Clearing');
  File file = await getSaveFile();
  file.delete();
}

void save() async {
  print('saving settings');
  //store user id, has done initial tutorial, and language locally
  File file = await getSaveFile();
  RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
  //user id
  await f.writeString('${globals.userID}\n');
  //has done initial tutorial
  await f.writeString('${globals.hasDoneTutorial}\n');
  //language
  await f.writeString('${globals.language}\n');
  //store everything else in Firestore
  if(globals.userID != '') {
    //sort
    String sort = globals.sort;
    //tags
    String tags = '';
    for(int i = 0; i < globals.tags.length; i++) {
      tags += '${globals.tags[i]};';
    }
    //brightness offset
    int brightness = globals.brightnessOffset;
    //red offset
    int red = globals.redOffset;
    //green offset
    int green = globals.greenOffset;
    //blue offset
    int blue = globals.blueOffset;
    //auto shade name mode
    int nameMode = globals.AutoShadeNameMode.values.indexOf(globals.autoShadeNameMode);
    //ColorWheelScreen distance
    double colorWheel = globals.colorWheelDistance;
    //save to database
    DocumentSnapshot docSnapshot;
    docSnapshot = await _database.doc(globals.userID).get();
    Map<String, dynamic> data = ((docSnapshot != null && docSnapshot.exists) ? docSnapshot.data() : {});
    await _database.doc(globals.userID).set(
        {
          'sort': sort,
          'tags': tags,
          'brightness': brightness,
          'red': red,
          'green': green,
          'blue': blue,
          'nameMode': nameMode,
          'colorWheel': colorWheel,
          'debug': data.containsKey('debug') ? data['debug'] : <String>[],
        }
    );
  }
}

Future<bool> load() async {
  File file = await getSaveFile();
  List<String> lines = (await file.readAsString()).split('\n');
  if(lines.length > 1) {
    //read user id, has done initial tutorial, and language locally
    //user id
    globals.userID = lines[0];
    //has done initial tutorial
    globals.hasDoneTutorial = (lines[1].toLowerCase() == 'true');
    //language
    globals.language = lines[2];
    //read everything else from Firestore
    if(globals.userID != '') {
      DocumentSnapshot docSnapshot = await _database.doc(globals.userID).get();
      if(docSnapshot == null || !docSnapshot.exists) {
        await save();
      } else {
        //sort
        globals.sort = docSnapshot.get('sort');
        //tags
        globals.tags = docSnapshot.get('tags').split(';');
        //brightness offset
        globals.brightnessOffset = docSnapshot.get('brightness');
        //red offset
        globals.redOffset = docSnapshot.get('red');
        //green offset
        globals.greenOffset = docSnapshot.get('green');
        //blue offset
        globals.blueOffset = docSnapshot.get('blue');
        //auto shade name mode
        globals.autoShadeNameMode = globals.AutoShadeNameMode.values[docSnapshot.get('nameMode')];
        //ColorWheelScreen distance
        globals.colorWheelDistance = docSnapshot.get('colorWheel') as double;
      }
    }
  } else {
    await save();
  }
  globals.hasLoaded = true;
  return globals.hasLoaded;
}

Future<void> addDebug(String debug) async {
  if(globals.userID != '') {
    try {
      DocumentReference doc = _database.doc(globals.userID);
      Map<String, dynamic> data = (await doc.get()).data();
      List<dynamic> prevDebug = data.containsKey('debug') ? data['debug'] : [];
      prevDebug.add(debug);
      await doc.update(
          {
            'debug': prevDebug,
          }
      );
    } catch(e) {
      print(e);
    }
  }
}

Future<void> clearDebug() async {
  if(globals.userID != '') {
    DocumentReference doc = _database.doc(globals.userID);
    await doc.update(
        {
          'debug': [],
        }
    );
  }
}