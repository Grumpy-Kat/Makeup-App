import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorProcessing.dart';
import 'ColorMath/ColorObjects.dart';
import 'globals.dart' as globals;
import 'theme.dart' as theme;
import 'routes.dart' as routes;

void main() => runApp(MakeupApp());

class MakeupApp extends StatelessWidget {
  static List<String> lines;
  static List<Swatch> swatches;
  static bool hasSaveChanged = true;

  @override
  Widget build(BuildContext context) {
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes(loadAllFormatted, saveAll, savePast);
    print(theme.bgColor);
    return MaterialApp(
      title: globals.appName,
      theme: ThemeData(
        backgroundColor: theme.bgColor,
        primaryColorLight: theme.primaryColorLight,
        primaryColor: theme.primaryColor,
        primaryColorDark: theme.primaryColorDark,
        accentColor: theme.accentColor,
        fontFamily: theme.fontFamily,
        primaryTextTheme: TextTheme(
          title: theme.primaryTitle,
          body1: theme.primaryText,
          body2: theme.primaryText,
          caption: theme.primaryTextSmall,
        ),
        accentTextTheme: TextTheme(
          title: theme.accentTitle,
          body1: theme.accentText,
          body2: theme.accentText,
          caption: theme.accentTextSmall,
        ),
      ),
      initialRoute: '/main0Screen',
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  //general save and load
  String _saveSwatch(Swatch swatch) {
    List<double> color = swatch.color.getValues();
    return color[0].toString() + ',' + color[1].toString() + ',' + color[2].toString() + ',' + swatch.finish + ',' + swatch.palette + '\n';
  }

  Future<String> _getLocalPath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //all swatches
  Future<File> _getSaveFileAll() async {
    final String path = await _getLocalPath();
    File file = File('$path/assets/save.txt');
    if(!(await file.exists())) {
      file = await file.create(recursive: true);
    }
    return file;
  }

  void clearAll() async {
    File file = await _getSaveFileAll();
    await file.writeAsString('');
  }

  void saveAll(List<Swatch> info) async {
    File file = await _getSaveFileAll();
    RandomAccessFile f = await file.open(mode: FileMode.writeOnlyAppend);
    print(info.length);
    for(int i = 0; i < info.length; i++) {
      await f.writeString(_saveSwatch(info[i]));
    }
  }

  Future<List<String>> loadAll() async {
    if(lines == null || hasSaveChanged) {
      File file = await _getSaveFileAll();
      lines = (await file.readAsString()).split('\n');
      for(int i = 0; i < lines.length; i++) {
        lines[i].trimRight();
      }
      hasSaveChanged = false;
    }
    return lines;
  }

  Future<List<Swatch>> loadAllFormatted() async {
    if(swatches == null || hasSaveChanged) {
      swatches = [];
      List<String> info = await loadAll();
      print(info.length);
      for(int i = 0; i < info.length - 1; i++) {
        List<String> line = info[i].split(',');
        swatches.add(Swatch(RGBColor(double.parse(line[0]), double.parse(line[1]), double.parse(line[2])), line[3], line[4]));
      }
      swatches.sort((a, b) => a.compareTo(b, (swatch) => stepSort(swatch.color, step: 8)));
      hasSaveChanged = false;
     }
    return swatches;
  }

  //past looks
  Future<File> _getSaveFilePastIds() async {
    final String path = await _getLocalPath();
    File file = File('$path/assets/savePastIds.txt');
    if(!(await file.exists())) {
      file = await file.create(recursive: true);
    }
    return file;
  }

  Future<File> _getSaveFilePast(int id) async {
    final String path = await _getLocalPath();
    File file = File('$path/assets/$id.txt');
    if(!(await file.exists())) {
      file = await file.create(recursive: true);
    }
    return file;
  }

  void clearPast(int id) async {
    File file = await _getSaveFilePast(id);
    await file.writeAsString('');
  }

  Future<int> savePast(int id, String name, List<Swatch> info) async  {
    if(id == -1) {
      //creating new saved look
      File fileAll = await _getSaveFilePastIds();
      int newId = int.parse((await fileAll.readAsString()).split('\n').last) + 1;
      RandomAccessFile fAll = await fileAll.open(mode: FileMode.writeOnlyAppend);
      await fAll.writeString(newId.toString());
      File file = await _getSaveFilePast(newId);
      RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
      await f.writeString(name + '\n');
      for(int i = 0; i < info.length; i++) {
        await f.writeString(_saveSwatch(info[i]));
      }
      return newId;
    } else {
      //editing saved look
      File file = await _getSaveFilePast(id);
      RandomAccessFile f = await file.open(mode: FileMode.writeOnly);
      await f.writeString(name + '\n');
      for(int i = 0; i < info.length; i++) {
        await f.writeString(_saveSwatch(info[i]));
      }
      return id;
    }
  }

  Future<List<String>> loadPast() async {
    //TODO: cache
    File fileAll = await _getSaveFilePastIds();
    List<String> ids = (await fileAll.readAsString()).split('\n');
    List<String> linesAll = [];
    for(int i = 0; i < ids.length; i++) {
      File file = await _getSaveFilePast(int.parse(ids[i]));
      List<String> lines = (await file.readAsString()).split('\n');
      for(int j = 0; j < lines.length; j++) {
        lines[i].trimRight();
        linesAll.add(lines[i]);
      }
      linesAll.add("");
    }
    return linesAll;
  }

  Future<Map<String, List<Swatch>>> loadPastFormatted() async {
    Map<String, List<Swatch>> swatches = {};
    List<Swatch> swatchList = [];
    String lastLabel = "";
    List<String> info = await loadAll();
    print(info.length);
    for(int i = 0; i < info.length - 1; i++) {
      if(info[i] == "") {
        print('line break ' + i.toString());
        swatchList.sort((a, b) => a.compareTo(b, (swatch) => stepSort(swatch.color, step: 8)));
        swatches[lastLabel] = swatchList;
        swatchList = [];
      }
      List<String> line = info[i].split(',');
      if(line.length == 1) {
        lastLabel = line[0];
        continue;
      }
      swatchList.add(Swatch(RGBColor(double.parse(line[0]), double.parse(line[1]), double.parse(line[2])), line[3], line[4]));
    }
    return swatches;
  }
}