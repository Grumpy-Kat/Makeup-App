import 'package:flutter/material.dart' hide HSVColor;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorConversions.dart';
import 'ColorMath/ColorProcessingTF.dart';
import 'Widgets/Swatch.dart';
import 'IO/settingsIO.dart' as IO;
import 'IO/loginIO.dart' as loginIO;
import 'IO/allSwatchesIO.dart' as allSwatchesIO;
import 'IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import 'IO/savedLooksIO.dart' as savedLooksIO;
import 'IO/presetPalettesIO.dart' as presetPalettesIO;
import 'IO/localizationIO.dart' as localizationIO;
import 'globals.dart' as globals;
import 'theme.dart' as theme;
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;

void main() => runApp(GlamKitApp());

class GlamKitApp extends StatefulWidget {
  @override
  GlamKitAppState createState() => GlamKitAppState();
}

class GlamKitAppState extends State<GlamKitApp> {
  @override
  Widget build(BuildContext context) {
    if(!globals.hasLoaded) {
      load().then((value) => setState(() { }));
    }
    return MaterialApp(
      title: globals.appName,
      theme: theme.themeData,
      home: _getHome(),
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  static Future<void> load() async {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    //FirebaseCrashlytics.instance.crash();
    await IO.init();
    if(!globals.hasLoaded) {
      await IO.load();
    }
    await loginIO.signIn();
    print(globals.userID);
    await localizationIO.load();
    theme.isDarkTheme = (WidgetsBinding.instance!.window.platformBrightness == Brightness.dark);
    //theme.isDarkTheme = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    globals.currSwatches.init();
    //globals.debug = !kReleaseMode;
    globals.debug = false;
    allSwatchesIO.init();
    allSwatchesStorageIO.init();
    savedLooksIO.init();
    presetPalettesIO.init();
    /*for(int i = 0; i < 3; i++) {
      for(int j = 0; j < 3; j++) {
        //await generateRainbow(saturation: (i * 0.2) + 0.2, value: (j * 0.2) + 0.2);
      }
    }*/
    //await generateRainbow(saturation: 0.5, value: 0.5);
    getModel();
    //await clearSave();
    //await IO.clear();
  }

  static Future<void> generateRainbow({ double saturation = 0.7, double value = 0.7 }) async {
    //await clearSave();
    Random random = Random();
    List<String> finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    List<Swatch> swatches = [];
    int numSwatches = 100;
    for(int i = 0; i < numSwatches; i++) {
      double hue = (341 / numSwatches * i).floorToDouble();
      RGBColor color = HSVtoRGB(HSVColor(hue, saturation, value));
      //print('$hue $saturation $value | ${color.getValues()[0]} ${color.getValues()[1]} ${color.getValues()[2]}');
      String finish = finishes[random.nextInt(finishes.length)];
      swatches.add(Swatch(color:color, finish: finish));
    }
    await allSwatchesIO.add(swatches);
  }

  Future<void> clearSave() async {
    //allSwatchesIO
    allSwatchesIO.clear();
    //savedLooksIO
    savedLooksIO.clearAll();
  }

  Widget _getHome() {
    print(globals.hasLoaded);
    print(globals.hasDoneTutorial);
    if(globals.hasLoaded) {
      if(globals.hasDoneTutorial) {
        navigation.init(routes.ScreenRoutes.AllSwatchesScreen);
        return routes.routes[routes.defaultRoute]!(null);
      } else {
        navigation.init(routes.ScreenRoutes.TutorialScreen);
        return routes.routes['/tutorialScreen']!(null);
      }
    }
    return Container();
  }
}