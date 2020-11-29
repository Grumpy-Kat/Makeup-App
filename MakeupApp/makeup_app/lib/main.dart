import 'package:flutter/material.dart' hide HSVColor;
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
    //generateRainbow();
    theme.isDarkTheme = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    //theme.isDarkTheme = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    globals.currSwatches.init();
    //globals.debug = !kReleaseMode;
    globals.debug = false;
    savedLooksIO.init();
    //clearSave();
    IO.load().then((value) { setState(() { }); });
  }

  void generateRainbow() async {
    await clearSave();
    Random random = Random();
    List<String> finishes = ['Matte', 'Satin', 'Shimmer', 'Metallic', 'Glitter'];
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
    /*//red
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 0) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor(125 + (130 / swatchesPerColor * i), 0, 0), finish: finish));
    }
    //orange
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 1) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor(125 + (130 / swatchesPerColor * i), (130 / swatchesPerColor * i), 0), finish: finish));
    }
    //yellow
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 2) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor(125 + (130 / swatchesPerColor * i), 125 + (130 / swatchesPerColor * i), 0), finish: finish));
    }
    //green
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 3) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor(0, 125 + (130 / swatchesPerColor * i), 0), finish: finish));
    }
    //blue
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 3) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor(0, 0, 125 + (130 / swatchesPerColor * i)), finish: finish));
    }
    //purple
    for(int i = 0; i < swatchesPerColor; i++) {
      String finish = finishes[random.nextInt(finishes.length)];
      info[(swatchesPerColor * 4) + i] = await globalIO.saveSwatch(Swatch(color: RGBColor((130 / swatchesPerColor * i), 0, 125 + (130 / swatchesPerColor * i)), finish: finish));
    }*/
    await allSwatchesIO.save(info);
  }

  void clearSave() async {
    //allSwatchesIO
    allSwatchesIO.clear();
    //savedLooksIO
    savedLooksIO.clearIds();
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