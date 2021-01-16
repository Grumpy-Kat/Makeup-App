import 'dart:io';
import 'dart:async';
import 'globalIO.dart';
import 'globals.dart' as globals;

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
  File file = await getSaveFile();
  RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
  //user id
  await f.writeString('${globals.userID}\n');
  //has done initial tutorial
  await f.writeString('${globals.hasDoneTutorial}\n');
  //language
  await f.writeString('${globals.language}\n');
  //sort
  await f.writeString('${globals.sort}\n');
  //tags
  String tags = '';
  for(int i = 0; i < globals.tags.length; i++) {
    tags += '${globals.tags[i]};';
  }
  await f.writeString('$tags\n');
  //brightness offset
  await f.writeString('${globals.brightnessOffset}\n');
  //red offset
  await f.writeString('${globals.redOffset}\n');
  //green offset
  await f.writeString('${globals.greenOffset}\n');
  //blue offset
  await f.writeString('${globals.blueOffset}\n');
  //auto shade name mode
  await f.writeString('${globals.AutoShadeNameMode.values.indexOf(globals.autoShadeNameMode)}\n');
  //ColorWheelScreen distance
  await f.writeString('${globals.colorWheelDistance}\n');
}

Future<bool> load() async {
  File file = await getSaveFile();
  List<String> lines = (await file.readAsString()).split('\n');
  if(lines.length > 1) {
    //user id
    globals.userID = lines[0];
    //has done initial tutorial
    globals.hasDoneTutorial = (lines[1].toLowerCase() == 'true');
    //language
    globals.language = lines[2];
    //sort
    globals.sort = lines[3];
    //tags
    globals.tags = lines[4].split(';');
    //brightness offset
    globals.brightnessOffset = int.parse(lines[5]);
    //red offset
    globals.redOffset = int.parse(lines[6]);
    //green offset
    globals.greenOffset = int.parse(lines[7]);
    //blue offset
    globals.blueOffset = int.parse(lines[8]);
    //auto shade name mode
    globals.autoShadeNameMode = globals.AutoShadeNameMode.values[int.parse(lines[9])];
    //ColorWheelScreen distance
    globals.colorWheelDistance = double.parse(lines[10]);
  } else {
    await save();
  }
  globals.hasLoaded = true;
  return globals.hasLoaded;
}