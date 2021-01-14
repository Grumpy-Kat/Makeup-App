import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../localizationIO.dart';
import 'AddCustomPaletteScreen.dart';
import 'AddPaletteDividerScreen.dart';

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
      leftBar: IconButton(
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.arrow_back,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        onPressed: () {
          navigation.pushReplacement(
            context,
            Offset(-1, 0),
            routes.ScreenRoutes.AllSwatchesScreen,
            routes.routes['/allSwatchesScreen'](context),
          );
        },
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
            margin: EdgeInsets.only(top: 40, bottom: 20),
            child: Text('${getString('addPalette_chooseMode')} ', style: theme.primaryTextBold),
          ),
          //sets mode to palette divider
          FlatButton.icon(
            icon: Icon(Icons.crop, size: 20, color: theme.iconTextColor),
            label: Text('${getString('addPalette_paletteDivider')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
            AddPaletteDividerScreenState.reset();
              navigation.pushReplacement(
                context,
                Offset(1, 0),
                routes.ScreenRoutes.AddPaletteDividerScreen,
                routes.routes['/addPaletteDividerScreen'](context),
              );
            },
          ),
          //sets mode to custom
          FlatButton.icon(
            icon: Icon(Icons.colorize, size: 20, color: theme.iconTextColor),
            label: Text('${getString('addPalette_custom')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              AddPaletteScreen.onEnter(
                context,
                (String brand, String palette, double weight, double price) {
                  setState(() {
                    AddCustomPaletteScreenState.reset();
                    AddCustomPaletteScreenState.brand = brand;
                    AddCustomPaletteScreenState.palette = palette;
                    AddCustomPaletteScreenState.weight = weight;
                    AddCustomPaletteScreenState.price = price;
                    navigation.pushReplacement(
                      context,
                      Offset(1, 0),
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
