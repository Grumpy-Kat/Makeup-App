import 'package:flutter/material.dart' hide HSVColor;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorConversions.dart';
import 'Widgets/Swatch.dart';
import 'globals.dart' as globals;
import 'theme.dart' as theme;
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;
import 'settingsIO.dart' as IO;
import 'globalIO.dart' as globalIO;
import 'savedLooksIO.dart' as savedLooksIO;
import 'allSwatchesIO.dart' as allSwatchesIO;
import 'localizationIO.dart' as localizationIO;

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

  void load() async {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    //FirebaseCrashlytics.instance.crash();
    await IO.load();
    await globals.login();
    await localizationIO.load();
    //generateRainbow();
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    //theme.isDarkTheme = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    globals.currSwatches.init();
    //globals.debug = !kReleaseMode;
    globals.debug = false;
    allSwatchesIO.init();
    savedLooksIO.init();
    //await clearSave();
    //await IO.clear();
    setState(() { });
  }

  void generateRainbow() async {
    await clearSave();
    Random random = Random();
    List<String> finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    Map<int, String> info = {};
    int swatches = 100;
    for(int i = 0; i < swatches; i++) {
      double hue = (341 / swatches * i).floorToDouble();
      double saturation = 0.7;
      double value = 0.7;
      RGBColor color = HSVtoRGB(HSVColor(hue, saturation, value));
      //print('$hue $saturation $value | ${color.getValues()[0]} ${color.getValues()[1]} ${color.getValues()[2]}');
      String finish = finishes[random.nextInt(finishes.length)];
      info[i] = await globalIO.saveSwatch(Swatch(color:color, finish: finish));
    }
    await allSwatchesIO.save(info);
  }

  void clearSave() async {
    //allSwatchesIO
    allSwatchesIO.clear();
    //savedLooksIO
    savedLooksIO.clearAll();
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