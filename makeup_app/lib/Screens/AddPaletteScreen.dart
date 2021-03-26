import 'package:flutter/material.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../localizationIO.dart';
import 'Screen.dart';
import 'AddPaletteDividerScreen.dart';
import 'AddCustomPaletteScreen.dart';
import 'AddPresetPaletteScreen.dart';

class AddPaletteScreen extends StatefulWidget {
  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();

  static void onEnter(BuildContext context, void Function(String, String, double, double) onPressed) {
    //open dialog to enter palette name and brand
    globalWidgets.openPaletteTextDialog(
      context,
      getString('addPalette_popupInstructions'),
      onPressed,
    );
  }
}

class AddPaletteScreenState extends State<AddPaletteScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    //has just opened screen and hasn't chosen mode yet
    return getModeOptionScreen(context);
  }

  Widget getModeOptionScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      //back button
      leftBar: globalWidgets.getBackButton(
        () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AllSwatchesScreen,
          routes.routes['/allSwatchesScreen'](context),
        ),
      ),
      //help button
      rightBar: [
        globalWidgets.getHelpBtn(
          context,
          '${getString('help_addPalette_0')}\n\n'
          '${getString('help_addPalette_1')}\n\n',
        ),
      ],
      body: Column(
        children: <Widget>[
          //text
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 20),
            child: Text('${getString('addPalette_chooseMode')} ', style: theme.primaryTextBold),
          ),
          //sets mode to palette divider
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.crop, size: 20, color: theme.iconTextColor),
            label: Text('${getString('addPalette_paletteDivider')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
            AddPaletteDividerScreenState.reset();
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AddPaletteDividerScreen,
                routes.routes['/addPaletteDividerScreen'](context),
              );
            },
          ),
          const SizedBox(
            height: 7,
          ),
          //sets mode to preset palette gallery
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.list, size: 20, color: theme.iconTextColor),
            label: Text('Preset Palettes', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              AddPresetPaletteScreenState.reset();
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AddPresetPaletteScreen,
                routes.routes['/addPresetPaletteScreen'](context),
              );
            },
          ),
          const SizedBox(
            height: 7,
          ),
          //sets mode to custom
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.colorize, size: 20, color: theme.iconTextColor),
            label: Text('${getString('addPalette_custom')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              AddPaletteScreen.onEnter(
                context,
                (String brand, String palette, double weight, double price) {
                  setState(() {
                    AddCustomPaletteScreenState.reset();
                    AddCustomPaletteScreenState.setValues(brand, palette, weight, price);
                    navigation.pushReplacement(
                      context,
                      const Offset(1, 0),
                      routes.ScreenRoutes.AddCustomPaletteScreen,
                      routes.routes['/addCustomPaletteScreen'](context),
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
