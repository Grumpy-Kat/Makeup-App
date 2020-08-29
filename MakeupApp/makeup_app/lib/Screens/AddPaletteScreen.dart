import 'package:flutter/material.dart';
import '../Widgets/Swatch.dart';
import '../Screens/Screen.dart';
import '../Widgets/PaletteDivider.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../navigation.dart' as navigation;
import '../allSwatchesIO.dart' as IO;

class AddPaletteScreen extends StatefulWidget {
  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();
}

class AddPaletteScreenState extends State<AddPaletteScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      10,
      PaletteDivider(
        onEnter: (List<Swatch> swatches) { onEnter(context, swatches); },
      ),
    );
  }

  void onEnter(BuildContext context, List<Swatch> swatches) {
    globalWidgets.openTwoTextDialog(
      context,
      'Enter a brand and name for this palette:',
      'Brand', 'Palette',
      'You must add a brand.',
      'You must add a palette name.',
      'Save',
      (String brand, String palette) {
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
        }
        IO.add(swatches);
        setState(() {
          navigation.pushReplacement(
            context,
            Offset(-1, 0),
            routes.ScreenRoutes.Main0Screen,
            routes.routes['/main0Screen'](context),
          );
        });
      }
    );
  }
}
