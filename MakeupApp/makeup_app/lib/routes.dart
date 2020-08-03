import 'package:flutter/material.dart';
import 'Screens/Main0Screen.dart';
import 'Screens/Main1Screen.dart';
import 'Screens/Main2Screen.dart';
import 'Screens/Main3Screen.dart';
import 'Screens/SettingsScreen.dart';
import 'Screens/AddPaletteScreen.dart';
import 'Screens/TodayLookScreen.dart';
import 'Screens/SavedLookScreen.dart';
import 'Widgets/Swatch.dart';

Map<String, StatefulWidget Function(BuildContext)> routes = {};

void setRoutes(Future<List<Swatch>> Function() loadFormatted, void Function(List<Swatch>) save, void Function(int, String, List<Swatch>) savePast) {
  routes = {
    '/main0Screen': (context) => Main0Screen(loadFormatted),
    '/main1Screen': (context) => Main1Screen(loadFormatted),
    '/main2Screen': (context) => Main2Screen(loadFormatted),
    '/main3Screen': (context) => Main3Screen(loadFormatted),
    '/settingsScreen': (context) => SettingsScreen(loadFormatted),
    '/addPaletteScreen': (context) => AddPaletteScreen(save),
    '/todayLookScreen': (context) => TodayLookScreen(loadFormatted, savePast),
    '/savedLookScreen': (context, { int id = -1, String name = '', List<Swatch> swatches }) => SavedLookScreen(loadFormatted, savePast, id: id, name: name, swatches: (swatches == null ? [] : swatches)),
  };
}