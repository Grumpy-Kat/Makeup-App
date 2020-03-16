import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'Screens/Main0Screen.dart';
import 'Screens/Main1Screen.dart';
import 'Screens/Main2Screen.dart';
import 'Screens/AddPaletteScreen.dart';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorProcessing.dart';
import 'ColorMath/ColorObjects.dart';

void main() => runApp(MakeupApp());

class MakeupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makeup App',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[800],
        primaryColorLight: Colors.blueGrey[700],
        primaryColorDark: Colors.blueGrey[900],
        accentColor: Colors.teal[400],
        fontFamily: 'Arial',
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),
          body1: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      initialRoute: '/addPalette',
      routes: {
        '/addPalette': (context) => AddPaletteScreen(save),
      },
    );
  }

  Future<String> _getLocalPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    print(directory.absolute);
    return directory.path;
  }

  Future<File> _getSaveFile() async {
    final String path = await _getLocalPath();
    return File('$path/assets/save.txt');
  }

  void save(List<Swatch> info) async {
    File file = await _getSaveFile();
    RandomAccessFile f = await file.open(mode: FileMode.writeOnlyAppend);
    for(int i = 0; i < info.length; i++) {
      List<double> color = info[i].color.getValues();
      f.writeString(color[0].toString() + ',' + color[1].toString() + ',' + color[2].toString() + ',' + info[i].finish + ',' + info[i].palette + '\n');
    }
  }

  Future<List<String>> load() async {
    File file = await _getSaveFile();
    List<String> lines = (await file.readAsString()).split('\n');
    for(int i = 0; i < lines.length; i++) {
      lines[i].trimRight();
    }
    return lines;
  }

  List<Swatch> loadFormatted() {
    List<Swatch> swatches = [];
    load().then((List<String> info) {
      for (int i = 0; i < info.length; i++) {
        List<String> line = info[i].split(',');
        swatches.add(Swatch(RGBColor(double.parse(line[0]), double.parse(line[1]), double.parse(line[2])), line[3], line[4]));
      }
      swatches.sort((a, b) => a.compareTo(b, (swatch) => stepSort(swatch.color, step: 8)));
    });
    return swatches;
  }
}