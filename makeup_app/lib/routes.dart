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
import 'Screens/AddPresetPaletteScreen.dart';
import 'Screens/TodayLookScreen.dart';
import 'Screens/SavedLookScreen.dart';
import 'Screens/SwatchScreen.dart';
import 'Login/LoginScreen.dart';
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
  AddPresetPaletteScreen,
  TodayLookScreen,
  SavedLookScreen,
  SwatchScreen,
  LoginScreen,
}

void setRoutes() {
  routes = {
    '/tutorialScreen': (context, [shouldReset = false]) => TutorialScreen(),
    '/allSwatchesScreen': (context, [shouldReset = false]) => AllSwatchesScreen(),
    '/savedLooksScreen': (context, [shouldReset = false]) => SavedLooksScreen(),
    '/colorWheelScreen': (context, [shouldReset = false]) => ColorWheelScreen(),
    '/paletteScannerScreen': (context, [shouldReset = false]) => PaletteScannerScreen(reset: shouldReset),
    '/randomizeLookScreen': (context, [shouldReset = false]) => RandomizeLookScreen(),
    '/settingsScreen': (context, [shouldReset = false]) => SettingsScreen(),
    '/addPaletteScreen': (context, [shouldReset = false]) => AddPaletteScreen(),
    '/addPaletteDividerScreen': (context, [shouldReset = false]) => AddPaletteDividerScreen(reset: shouldReset),
    '/addCustomPaletteScreen': (context, [shouldReset = false]) => AddCustomPaletteScreen(reset: shouldReset),
    '/addPresetPaletteScreen': (context, [shouldReset = false]) => AddPresetPaletteScreen(reset: shouldReset),
    '/todayLookScreen': (context, [shouldReset = false]) => TodayLookScreen(),
    '/savedLookScreen': (context, [shouldReset = false]) => SavedLookScreen(look: null),
    '/swatchScreen': (context, [shouldReset = false]) => SwatchScreen(swatch: null),
    '/loginScreen': (context, [shouldReset = false]) => LoginScreen(true),
  };
  enumRoutes = {
    ScreenRoutes.TutorialScreen: routes['/tutorialScreen']!,
    ScreenRoutes.AllSwatchesScreen: routes['/allSwatchesScreen']!,
    ScreenRoutes.SavedLooksScreen: routes['/savedLooksScreen']!,
    ScreenRoutes.ColorWheelScreen: routes['/colorWheelScreen']!,
    ScreenRoutes.PaletteScannerScreen: routes['/paletteScannerScreen']!,
    ScreenRoutes.RandomizeLookScreen: routes['/randomizeLookScreen']!,
    ScreenRoutes.SettingsScreen: routes['/settingsScreen']!,
    ScreenRoutes.AddPaletteScreen: routes['/addPaletteScreen']!,
    ScreenRoutes.AddPaletteDividerScreen: routes['/addPaletteDividerScreen']!,
    ScreenRoutes.AddCustomPaletteScreen: routes['/addCustomPaletteScreen']!,
    ScreenRoutes.AddPresetPaletteScreen: routes['/addPresetPaletteScreen']!,
    ScreenRoutes.TodayLookScreen: routes['/todayLookScreen']!,
    ScreenRoutes.SavedLookScreen: routes['/savedLookScreen']!,
    ScreenRoutes.SwatchScreen: routes['/swatchScreen']!,
    ScreenRoutes.LoginScreen: routes['/loginScreen']!,
  };
}