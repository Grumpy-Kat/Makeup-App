import 'Screens/AllSwatchesScreen.dart';
import 'Screens/ColorWheelScreen.dart';
import 'Screens/PaletteScannerScreen.dart';
import 'Screens/SavedLooksScreen.dart';
import 'Screens/SettingsScreen.dart';
import 'Screens/AddPaletteScreen.dart';
import 'Screens/TodayLookScreen.dart';
import 'Screens/SavedLookScreen.dart';
import 'Screens/SwatchScreen.dart';
import 'types.dart';

Map<String, OnScreenAction> routes = {};
Map<ScreenRoutes, OnScreenAction> enumRoutes = {};

enum ScreenRoutes {
  AllSwatchesScreen,
  SavedLooksScreen,
  ColorWheelScreen,
  PaletteScannerScreen,
  SettingsScreen,
  AddPaletteScreen,
  TodayLookScreen,
  SavedLookScreen,
  SwatchScreen,
}

void setRoutes() {
  routes = {
    '/allSwatchesScreen': (context) => AllSwatchesScreen(),
    '/savedLooksScreen': (context) => SavedLooksScreen(),
    '/colorWheelScreen': (context) => ColorWheelScreen(),
    '/paletteScannerScreen': (context) => PaletteScannerScreen(),
    '/settingsScreen': (context) => SettingsScreen(),
    '/addPaletteScreen': (context) => AddPaletteScreen(),
    '/todayLookScreen': (context) => TodayLookScreen(),
    '/savedLookScreen': (context) => SavedLookScreen(id: -1, name: '', swatches: []),
    '/swatchScreen': (context) => SwatchScreen(swatch: null),
  };
  enumRoutes = {
    ScreenRoutes.AllSwatchesScreen: routes['/allSwatchesScreen'],
    ScreenRoutes.SavedLooksScreen: routes['/savedLooksScreen'],
    ScreenRoutes.ColorWheelScreen: routes['/colorWheelScreen'],
    ScreenRoutes.PaletteScannerScreen: routes['/paletteScannerScreen'],
    ScreenRoutes.SettingsScreen: routes['/settingsScreen'],
    ScreenRoutes.AddPaletteScreen: routes['/addPaletteScreen'],
    ScreenRoutes.TodayLookScreen: routes['/todayLookScreen'],
    ScreenRoutes.SavedLookScreen: routes['/savedLookScreen'],
    ScreenRoutes.SwatchScreen: routes['/swatchScreen'],
  };
}