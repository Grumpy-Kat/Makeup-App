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
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    IO.load();
    globals.currSwatches.init();
    globals.debug = !kReleaseMode;
    globals.debug = false;
    savedLooks.init();
    navigation.init(routes.ScreenRoutes.Main0Screen);
    return MaterialApp(
      title: globals.appName,
      theme: theme.themeData,
      initialRoute: '/main0Screen',
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}