import 'package:flutter/material.dart';
import '../ColorMath/ColorObjects.dart';
import '../Screens/Screen.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/PaletteDivider.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../allSwatchesIO.dart' as IO;
import '../localizationIO.dart';

class AddPaletteScreen extends StatefulWidget {
  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();
}

class AddPaletteScreenState extends State<AddPaletteScreen> with ScreenState {
  static bool _hasChosenMode = false;
  static bool _isUsingPaletteDivider = true;
  static bool _displayCheckButton = false;

  static String _brand = '';
  static String _palette = '';
  static double _weight = 0.0;
  static double _price = 0.00;

  static List<int> _swatches = [];
  static List<SwatchIcon> _swatchIcons = [];

  void _addSwatchIcons() {
    _swatchIcons.clear();
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
    //has just opened screen and hasn't chosen mode yet
    if(!_hasChosenMode) {
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
            //sets mode ot palette divider
            FlatButton.icon(
              icon: Icon(Icons.crop, size: 20, color: theme.iconTextColor),
              label: Text('${getString('addPalette_paletteDivider')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
              onPressed: () {
                setState(() {
                  _isUsingPaletteDivider = true;
                  _hasChosenMode = true;
                });
              },
            ),
            //sets mode to custom
            FlatButton.icon(
              icon: Icon(Icons.colorize, size: 20, color: theme.iconTextColor),
              label: Text('${getString('addPalette_custom')}', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
              onPressed: () {
                onEnter(
                  context,
                  (String brand, String palette, double weight, double price) {
                    setState(() {
                      _brand = brand;
                      _palette = palette;
                      _weight = weight;
                      _price = price;
                      _isUsingPaletteDivider = false;
                      _hasChosenMode = true;
                    });
                  },
                );
              },
            ),
          ],
        ),
      );
    }
    //using palette divider, but hasn't finished
    if(_hasChosenMode && _isUsingPaletteDivider && !_displayCheckButton) {
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
            setState(() {
              _hasChosenMode = false;
            });
          },
        ),
        //help button
        rightBar: [
          globalWidgets.getHelpBtn(
            context,
            '${getString('help_addPalette_2')}\n\n'
            '${getString('help_addPalette_3')}\n\n'
            '${getString('help_addPalette_4')}\n\n'
            '${getString('help_addPalette_5')}\n\n'
            '${getString('help_addPalette_6')}\n\n',
          ),
        ],
        //palette divider
        body: PaletteDivider(
          onEnter: (List<Swatch> swatches) { onEnterPaletteDivider(context, swatches); },
        ),
      );
    }
    //using palette divider, but has finished OR not using palette divider
    if(_hasChosenMode && ((_isUsingPaletteDivider && _displayCheckButton) || !_isUsingPaletteDivider)) {
      //check button to complete
      Widget checkButton = Container(
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
      );
      //total floating action buttons, can change based on condition
      Widget floatingAction;
      if(!_isUsingPaletteDivider) {
        //column of check and plus button
        //if using custom, need to have plus button to add swatches
        floatingAction = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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
                  double weightPer = double.parse((_weight / (_swatches.length + 1)).toStringAsFixed(4));
                  double pricePer = double.parse((_price / (_swatches.length + 1)).toStringAsFixed(2));
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
                      brand: _brand,
                      palette: _palette,
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
                      });
                    }
                  );
                },
              ),
            ),
            checkButton,
          ],
        );
      } else {
        //only check button
        //if using palette divider, does not need plus button
        floatingAction = checkButton;
      }
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
            setState(() {
              _hasChosenMode = false;
            });
          },
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
        floatingActionButton: floatingAction,
      );
    }
    //show error because condition shouldn't be reachable
    print('Has reached impossible point!');
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      body: Text(
        getString('error'),
        style: theme.errorText,
      ),
    );
  }

  void onEnter(BuildContext context, void Function(String, String, double, double) onPressed) {
    //open dialog to enter palette name and brand
    globalWidgets.openPaletteTextDialog(
      context,
      getString('addPalette_popupInstructions'),
      onPressed,
    );
  }

  void onEnterPaletteDivider(BuildContext context, List<Swatch> swatches) {
    onEnter(
      context,
      (String brand, String palette, double weight, double price) {
        _brand = brand;
        _palette = palette;
        _weight = weight;
        _price = price;
        //assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
          swatches[i].weight = double.parse((weight / swatches.length).toStringAsFixed(4));
          swatches[i].price = double.parse((price / swatches.length).toStringAsFixed(2));
        }
        //saves swatches and adds them to final list to display
        IO.add(swatches).then((List<int> val) {
          setState(() {
            _swatches = val;
            _addSwatchIcons();
            _displayCheckButton = true;
          });
        });
      }
    );
  }

  void onCheckButton() {
    onExit();
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

  @override
  void onExit() {
    super.onExit();
    //reset all modes and data
    _hasChosenMode = false;
    _displayCheckButton = false;
    _swatches = [];
    _swatchIcons = [];
  }
}
