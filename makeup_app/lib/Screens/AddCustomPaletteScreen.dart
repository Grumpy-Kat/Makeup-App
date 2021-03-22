import 'package:flutter/material.dart';
import '../ColorMath/ColorObjects.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Palette.dart';
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

  //doesn't actually contain swatches, just other values
  static Palette _palette;

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
      leftBar: globalWidgets.getBackButton(
        () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen'](context),
        ),
      ),
      rightBar: [
        //delete button
        Container(
          margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: IconButton(
            constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
            color: theme.primaryColor,
            onPressed: () {
              globalWidgets.openTwoButtonDialog(
                context,
                '${getString('addCustomPalette_popupInstructions')}',
                () {
                  globalWidgets.openLoadingDialog(context);
                  IO.removeIDsMany(_swatches);
                  Navigator.pop(context);
                  navigation.pushReplacement(
                    context,
                    const Offset(-1, 0),
                    routes.ScreenRoutes.AddPaletteScreen,
                    routes.routes['/addPaletteScreen'](context),
                  );
                },
                () { },
              );
            },
            icon: Icon(
              Icons.delete,
              size: theme.quaternaryIconSize,
              color: theme.tertiaryTextColor,
              semanticLabel: 'Delete Filtered Swatches',
            ),
          ),
        ),
      ],
      //scroll view to show all swatches
      body: GridView.builder(
        scrollDirection: Axis.vertical,
        primary: true,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            margin: const EdgeInsets.only(right: 8, bottom: 13),
            width: 57,
            height: 57,
            child: FloatingActionButton(
              heroTag: 'AddPaletteScreen Plus',
              backgroundColor: theme.accentColor,
              child: Icon(
                Icons.add,
                size: 36,
                color: theme.accentTextColor,
              ),
              onPressed: () {
                globalWidgets.openLoadingDialog(context);
                double weightPer = double.parse((_palette.weight / (_swatches.length + 1)).toStringAsFixed(4));
                double pricePer = double.parse((_palette.price / (_swatches.length + 1)).toStringAsFixed(2));
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
                    brand: _palette.brand,
                    palette: _palette.name,
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
            margin: EdgeInsets.only(right: 15, bottom: (MediaQuery.of(context).size.height * 0.1) + 15),
            width: 65,
            height: 65,
            child: FloatingActionButton(
              heroTag: 'AddPaletteScreen Check',
              backgroundColor: theme.checkTextColor,
              child: Icon(
                Icons.check,
                size: 40,
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
        const Offset(-1, 0),
        routes.ScreenRoutes.AllSwatchesScreen,
        routes.routes['/allSwatchesScreen'](context),
      );
    });
  }

  static void setValues(String brand, String palette, double weight, double price) {
    //doesn't actually contain swatches, just other values
    _palette = Palette(
      id: '',
      brand: brand,
      name: palette,
      weight: weight,
      price: price,
      swatches: [],
    );
  }

  static void reset() {
    //reset all modes and data
    _swatches = [];
    _swatchIcons = [];
    _palette = null;
  }
}
