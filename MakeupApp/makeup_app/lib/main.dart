import 'package:GlamKit/Screens/AllSwatchesScreen.dart';
import 'package:GlamKit/Screens/TutorialScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'globals.dart' as globals;
import 'theme.dart' as theme;
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;
import 'settingsIO.dart' as IO;
import 'savedLooksIO.dart' as savedLooks;

void main() => runApp(MakeupApp());

class MakeupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    IO.load();
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    globals.currSwatches.init();
    globals.debug = !kReleaseMode;
    savedLooks.init();
    return MaterialApp(
      title: globals.appName,
      theme: theme.themeData,
      home: _getHome(),
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getHome() {
    if(globals.hasLoaded) {
      if(globals.hasDoneTutorial) {
        navigation.init(routes.ScreenRoutes.AllSwatchesScreen);
        return routes.routes['/allSwatchesScreen'](null);
      } else {
        navigation.init(routes.ScreenRoutes.TutorialScreen);
        return routes.routes['/tutorialScreen'](null);
      }
    }
    //TODO: add splash screen
    return Container();
  }
}