import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'globals.dart' as globals;
import 'theme.dart' as theme;
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;
import 'settingsIO.dart' as IO;
import 'savedLooksIO.dart' as savedLooksIO;
import 'allSwatchesIO.dart' as allSwatchesIO;

void main() => runApp(GlamKitApp());

class GlamKitApp extends StatefulWidget {
  @override
  GlamKitAppState createState() => GlamKitAppState();
}

class GlamKitAppState extends State<GlamKitApp> {
  @override
  Widget build(BuildContext context) {
    if(!globals.hasLoaded) {
      load();
    }
    return MaterialApp(
      title: globals.appName,
      theme: theme.themeData,
      home: _getHome(),
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  void load() {
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    globals.currSwatches.init();
    globals.debug = !kReleaseMode;
    savedLooksIO.init();
    //newSave();
    IO.load().then((value) { setState(() { }); });
  }

  void newSave() async {
    //allSwatchesIO
    await allSwatchesIO.loadFormatted();
    allSwatchesIO.save(await allSwatchesIO.load());
    //savedLooksIO
    Map<String, List<int>> savedLooks = await savedLooksIO.loadFormatted();
    for(int i = 0; i < savedLooks.keys.length; i++) {
      List<String> labelSplit = savedLooks.keys.toList()[i].split('|');
      savedLooksIO.save(int.parse(labelSplit[0]), labelSplit[1], savedLooks[savedLooks.keys.toList()[i]]);
    }
  }

  Widget _getHome() {
    if(globals.hasLoaded) {
      if(globals.hasDoneTutorial) {
        navigation.init(routes.ScreenRoutes.AllSwatchesScreen);
        return routes.routes[routes.defaultRoute](null);
      } else {
        navigation.init(routes.ScreenRoutes.TutorialScreen);
        return routes.routes['/tutorialScreen'](null);
      }
    }
    return Container();
  }
}