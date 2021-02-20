import 'Screens/TutorialScreen.dart';
import 'Screens/AllSwatchesScreen.dart';
import 'Screens/SavedLooksScreen.dart';
import 'Screens/ColorWheelScreen.dart';
import 'Screens/PaletteScannerScreen.dart';
import 'Screens/RandomizeLookScreen.dart';
import 'Screens/SettingsScreen.dart';
import 'Screens/AddPaletteScreen.dart';
import 'Screens/AddPaletteDividerScreen.dart';
import 'Screens/AddCustomPaletteScreen.dart';
import 'Screens/TodayLookScreen.dart';
import 'Screens/SavedLookScreen.dart';
import 'Screens/SwatchScreen.dart';
import 'types.dart';

Map<String, OnScreenAction> routes = {};
Map<ScreenRoutes, OnScreenAction> enumRoutes = {};

String defaultRoute = '/allSwatchesScreen';
ScreenRoutes defaultEnumRoute = ScreenRoutes.AllSwatchesScreen;

enum ScreenRoutes {
  TutorialScreen,
  AllSwatchesScreen,
  SavedLooksScreen,
  ColorWheelScreen,
  PaletteScannerScreen,
  RandomizeLookScreen,
  SettingsScreen,
  AddPaletteScreen,
  AddPaletteDividerScreen,
  AddCustomPaletteScreen,
  TodayLookScreen,
  SavedLookScreen,
  SwatchScreen,
}

void setRoutes() {
  routes = {
    '/tutorialScreen': (context) => TutorialScreen(),
    '/allSwatchesScreen': (context) => AllSwatchesScreen(),
    '/savedLooksScreen': (context) => SavedLooksScreen(),
    '/colorWheelScreen': (context) => ColorWheelScreen(),
    '/paletteScannerScreen': (context) => PaletteScannerScreen(),
    '/randomizeLookScreen': (context) => RandomizeLookScreen(),
    '/settingsScreen': (context) => SettingsScreen(),
    '/addPaletteScreen': (context) => AddPaletteScreen(),
    '/addPaletteDividerScreen': (context) => AddPaletteDividerScreen(),
    '/addCustomPaletteScreen': (context) => AddCustomPaletteScreen(),
    '/todayLookScreen': (context) => TodayLookScreen(),
    '/savedLookScreen': (context) => SavedLookScreen(look: null),
    '/swatchScreen': (context) => SwatchScreen(swatch: null),
  };
  enumRoutes = {
    ScreenRoutes.TutorialScreen: routes['/tutorialScreen'],
    ScreenRoutes.AllSwatchesScreen: routes['/allSwatchesScreen'],
    ScreenRoutes.SavedLooksScreen: routes['/savedLooksScreen'],
    ScreenRoutes.ColorWheelScreen: routes['/colorWheelScreen'],
    ScreenRoutes.PaletteScannerScreen: routes['/paletteScannerScreen'],
    ScreenRoutes.RandomizeLookScreen: routes['/randomizeLookScreen'],
    ScreenRoutes.SettingsScreen: routes['/settingsScreen'],
    ScreenRoutes.AddPaletteScreen: routes['/addPaletteScreen'],
    ScreenRoutes.AddPaletteDividerScreen: routes['/addPaletteDividerScreen'],
    ScreenRoutes.AddCustomPaletteScreen: routes['/addCustomPaletteScreen'],
    ScreenRoutes.TodayLookScreen: routes['/todayLookScreen'],
    ScreenRoutes.SavedLookScreen: routes['/savedLookScreen'],
    ScreenRoutes.SwatchScreen: routes['/swatchScreen'],
  };
}