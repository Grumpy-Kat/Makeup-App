import 'Screens/Main0Screen.dart';
import 'Screens/Main1Screen.dart';
import 'Screens/Main2Screen.dart';
import 'Screens/Main3Screen.dart';
import 'Screens/SettingsScreen.dart';
import 'Screens/AddPaletteScreen.dart';
import 'Screens/TodayLookScreen.dart';
import 'Screens/SavedLookScreen.dart';
import 'Screens/SwatchScreen.dart';
import 'types.dart';

Map<String, OnScreenAction> routes = {};
Map<ScreenRoutes, OnScreenAction> enumRoutes = {};

enum ScreenRoutes {
  Main0Screen,
  Main1Screen,
  Main2Screen,
  Main3Screen,
  SettingsScreen,
  AddPaletteScreen,
  TodayLookScreen,
  SavedLookScreen,
  SwatchScreen,
}

void setRoutes() {
  routes = {
    '/main0Screen': (context) => Main0Screen(),
    '/main1Screen': (context) => Main1Screen(),
    '/main2Screen': (context) => Main2Screen(),
    '/main3Screen': (context) => Main3Screen(),
    '/settingsScreen': (context) => SettingsScreen(),
    '/addPaletteScreen': (context) => AddPaletteScreen(),
    '/todayLookScreen': (context) => TodayLookScreen(),
    '/savedLookScreen': (context) => SavedLookScreen(id: -1, name: '', swatches: []),
    '/swatchScreen': (context) => SwatchScreen(swatch: null),
  };
  enumRoutes = {
    ScreenRoutes.Main0Screen: routes['/main0Screen'],
    ScreenRoutes.Main1Screen: routes['/main1Screen'],
    ScreenRoutes.Main2Screen: routes['/main2Screen'],
    ScreenRoutes.Main3Screen: routes['/main3Screen'],
    ScreenRoutes.SettingsScreen: routes['/settingsScreen'],
    ScreenRoutes.AddPaletteScreen: routes['/addPaletteScreen'],
    ScreenRoutes.TodayLookScreen: routes['/todayLookScreen'],
    ScreenRoutes.SavedLookScreen: routes['/savedLookScreen'],
    ScreenRoutes.SwatchScreen: routes['/swatchScreen'],
  };
}