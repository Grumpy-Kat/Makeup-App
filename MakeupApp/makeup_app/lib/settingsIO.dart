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
}

void load() async {
  File file = await getSaveFile();
  List<String> lines = (await file.readAsString()).split('\n');
  //language
  globals.language = lines[0];
  //sort
  globals.sort = lines[1];
  //tags
  globals.tags = lines[2].split(';');
}