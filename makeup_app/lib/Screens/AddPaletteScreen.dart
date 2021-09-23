import 'package:flutter/material.dart' hide BackButton;
import '../IO/localizationIO.dart';
import '../Widgets/SwatchImage.dart';
import '../Widgets/PaletteTextPopup.dart';
import '../Widgets/BackButton.dart';
import '../Widgets/HelpButton.dart';
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import 'Screen.dart';
import 'AddCustomPaletteScreen.dart';

class AddPaletteScreen extends StatefulWidget {
  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();

  static Future<void> onEnter(BuildContext context, void Function(String, String, double, double, DateTime?, DateTime?, List<SwatchImage>) onPressed, { bool showRequired = true, bool showNums = true, bool showDates = true, bool showImgs = true }) {
    //open dialog to enter palette name and brand
    return PaletteTextPopup.open(
      context,
      getString('addPalette_popupInstructions'),
      onPressed,
      showRequired: showRequired,
      showNums: showNums,
      showDates: showDates,
      showImgs: showImgs,
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
      leftBar: BackButton(
        onPressed: () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AllSwatchesScreen,
          routes.routes['/allSwatchesScreen']!(context),
        ),
      ),
      //help button
      rightBar: [
        HelpButton(
          text: '${getString('help_addPalette_0')}\n\n'
          '${getString('help_addPalette_1')}\n\n'
          '${getString('help_addPalette_2')}\n\n',
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
              //AddPaletteDividerScreenState.reset();
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AddPaletteDividerScreen,
                routes.routes['/addPaletteDividerScreen']!(context, true),
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
            label: Text('${getString('addPalette_presetPalettes')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              //AddPresetPaletteScreenState.reset();
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AddPresetPaletteScreen,
                routes.routes['/addPresetPaletteScreen']!(context, true),
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
                (String brand, String palette, double weight, double price, DateTime? openDate, DateTime? expirationDate, List<SwatchImage> imgs) {
                  setState(() {
                    AddCustomPaletteScreenState.reset();
                    AddCustomPaletteScreenState.setValues(brand, palette, weight, price, openDate, expirationDate);
                    navigation.pushReplacement(
                      context,
                      const Offset(1, 0),
                      routes.ScreenRoutes.AddCustomPaletteScreen,
                      routes.routes['/addCustomPaletteScreen']!(context),
                    );
                  });
                },
                showImgs: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
