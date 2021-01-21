import 'package:flutter/material.dart';
import '../ColorMath/ColorObjects.dart';
import '../Widgets/Swatch.dart';
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../allSwatchesIO.dart' as IO;
import '../globalWidgets.dart' as globalWidgets;
import '../localizationIO.dart';
import 'Screen.dart';

class AddCustomPaletteScreen extends StatefulWidget {
  @override
  AddCustomPaletteScreenState createState() => AddCustomPaletteScreenState();
}

class AddCustomPaletteScreenState extends State<AddCustomPaletteScreen> with ScreenState {
  static List<int> _swatches = [];
  static List<SwatchIcon> _swatchIcons = [];

  static String brand = '';
  static String palette = '';
  static double weight = 0.0;
  static double price = 0.00;

  @override
  void initState() {
    super.initState();
    for(int i = _swatches.length - 1; i >= 0; i--) {
      if(IO.get(_swatches[i]) == null) {
        _swatches.removeAt(i);
      }
    }
    _addSwatchIcons();
  }

  void _addSwatchIcons() {
    _swatchIcons = [];
    //create icon widgets for all swatch data
    for(int i = 0; i < _swatches.length; i++) {
      _swatchIcons.add(
        SwatchIcon.id(
          _swatches[i],
          showInfoBox: true,
          showCheck: false,
          onDelete: null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      //back button
      leftBar: globalWidgets.getBackButton (() => navigation.pushReplacement(
          context,
          Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen'](context),
        )
      ),
      //scroll view to show all swatches
      body: GridView.builder(
        scrollDirection: Axis.vertical,
        primary: true,
        padding: EdgeInsets.all(20),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 30,
          crossAxisSpacing: 30,
          crossAxisCount: 4,
        ),
        itemCount: _swatchIcons.length,
        itemBuilder: (BuildContext context, int i) {
          return _swatchIcons[i];
        },
      ),
      //column of plus button and check button
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          //plus button to add swatches
          Container(
            margin: EdgeInsets.only(right: 0, bottom: 12.5),
            width: 63,
            height: 63,
            child: FloatingActionButton(
              heroTag: 'AddPaletteScreen Plus',
              backgroundColor: theme.accentColor,
              child: Icon(
                Icons.add,
                size: 38,
                color: theme.accentTextColor,
              ),
              onPressed: () {
                globalWidgets.openLoadingDialog(context);
                double weightPer = double.parse((weight / (_swatches.length + 1)).toStringAsFixed(4));
                double pricePer = double.parse((price / (_swatches.length + 1)).toStringAsFixed(2));
                List<Swatch> swatches = IO.getMany(_swatches);
                for(int i = 0; i < swatches.length; i++) {
                  swatches[i].weight = weightPer;
                  swatches[i].price = pricePer;
                  IO.editId(_swatches[i], swatches[i]);
                }
                IO.add([
                  Swatch(
                    color: RGBColor(0.5, 0.5, 0.5),
                    finish: 'finish_matte',
                    brand: brand,
                    palette: palette,
                    weight: weightPer,
                    price: pricePer,
                    shade: '',
                    rating: 5,
                    tags: [],
                  ),
                ]).then(
                  (List<int> val) {
                    setState(() {
                      _swatches.add(val[0]);
                      _addSwatchIcons();
                      Navigator.pop(context);
                    });
                  }
                );
              },
            ),
          ),
          //check button to complete
          Container(
            margin: EdgeInsets.only(right: 12.5, bottom: (MediaQuery.of(context).size.height * 0.1) + 12.5),
            width: 75,
            height: 75,
            child: FloatingActionButton(
              heroTag: 'AddPaletteScreen Check',
              backgroundColor: theme.checkTextColor,
              child: Icon(
                Icons.check,
                size: 45,
                color: theme.accentTextColor,
              ),
              onPressed: onCheckButton,
            ),
          ),
        ],
      ),
    );
  }

  void onCheckButton() {
    //return to AllSwatchesScreen
    setState(() {
      navigation.pushReplacement(
        context,
        Offset(-1, 0),
        routes.ScreenRoutes.AllSwatchesScreen,
        routes.routes['/allSwatchesScreen'](context),
      );
    });
  }

  static void reset() {
    //reset all modes and data
    _swatches = [];
    _swatchIcons = [];
  }
}
