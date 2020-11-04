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
}

void load() async {
  File file = await getSaveFile();
  List<String> lines = (await file.readAsString()).split('\n');
  if(lines.length > 1) {
    //language
    globals.language = lines[0];
    //sort
    globals.sort = lines[1];
    //tags
    globals.tags = lines[2].split(';');
    if(lines.length > 4) {
      //brightness offset
      globals.brightnessOffset = int.parse(lines[3]);
      //red offset
      globals.redOffset = int.parse(lines[4]);
      //green offset
      globals.greenOffset = int.parse(lines[5]);
      //blue offset
      globals.blueOffset = int.parse(lines[6]);
      //auto shade name mode
      globals.autoShadeNameMode = globals.AutoShadeNameMode.values[int.parse(lines[7])];
    }
  } else {
    await save();
  }
  globals.hasLoaded = true;
}