import 'package:GlamKit/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ColorMath/ColorObjects.dart';
import '../Screens/Screen.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/PaletteDivider.dart';
import '../globals.dart' as globals;
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

  static List<int> _swatches = [];
  static List<SwatchIcon> _swatchIcons = [];

  static List<double> _orgRed = [];
  static List<double> _orgGreen = [];
  static List<double> _orgBlue = [];
  static int _brightnessOffset = 0;
  static int _redOffset = 0;
  static int _greenOffset = 0;
  static int _blueOffset = 0;

  static String _brand = '';
  static String _palette = '';
  static double _weight = 0.0;
  static double _price = 0.00;

  @override
  void initState() {
    super.initState();
    _brightnessOffset = globals.brightnessOffset;
    _redOffset = globals.redOffset;
    _greenOffset = globals.greenOffset;
    _blueOffset = globals.blueOffset;
  }

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
      return getModeOptionScreen(context);
    }
    //using palette divider, but hasn't finished
    if(_hasChosenMode && _isUsingPaletteDivider && !_displayCheckButton) {
      return getPaletteDividerScreen(context);
    }
    //using palette divider, but has finished OR not using palette divider
    if(_hasChosenMode && _isUsingPaletteDivider && _displayCheckButton) {
      return getPaletteListScreen(context);
    }
    //not using palette divider
    if(_hasChosenMode && !_isUsingPaletteDivider) {
      return getCustomListScreen(context);
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

  Widget getPaletteDividerScreen(BuildContext context) {
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

  Widget getPaletteListScreen(BuildContext context) {
    //height of num fields
    double height = 55;
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15, vertical: 7);
    //outer container includes margin if no field below
    EdgeInsets margin = EdgeInsets.only(bottom: 10);
    //border and color if no field below
    Decoration decoration = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
        bottom: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    //border and color if field below
    Decoration decorationNoBottom = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
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
            reset();
          });
        },
      ),
      body: Column(
        children: <Widget> [
          //brightness offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_brightness')} ',
            _brightnessOffset,
            (int val) {
              _brightnessOffset = val;
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                IO.editId(_swatches[i], swatch);
              }
              setState(() {
                _addSwatchIcons();
              });
            },
          ),
          //red offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_red')} ',
            _redOffset,
            (int val) {
              _redOffset = val;
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                IO.editId(_swatches[i], swatch);
              }
              setState(() {
                _addSwatchIcons();
              });
            },
          ),
          //green offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_green')} ',
            _greenOffset,
            (int val) {
              for(int i = 0; i < _swatches.length; i++) {
                _greenOffset = val;
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                IO.editId(_swatches[i], swatch);
              }
              setState(() {
                _addSwatchIcons();
              });
            },
          ),
          //blue offset field
          getNumField(
            context,
            height,
            decoration,
            padding,
            margin,
            '${getString('settings_photo_blue')} ',
            _blueOffset,
            (int val) {
              _blueOffset = val;
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                IO.editId(_swatches[i], swatch);
              }
              setState(() {
                _addSwatchIcons();
              });
            }
          ),
          //scroll view to show all swatches
          Expanded(
            child: GridView.builder(
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
          ),
        ],
      ),
      //check button to complete
      floatingActionButton: Container(
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
    );
  }

  Widget getNumField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin, String title, int value, OnIntAction onChanged) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text(title, style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  initialValue: value.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    onChanged(int.parse(val));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getCustomListScreen(BuildContext context) {
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
            reset();
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
          _orgRed.add((swatches[i].color.values['rgbR'] - (globals.brightnessOffset / 255.0)) - (globals.redOffset / 255.0));
          _orgGreen.add((swatches[i].color.values['rgbG'] - (globals.brightnessOffset / 255.0)) - (globals.greenOffset / 255.0));
          _orgBlue.add((swatches[i].color.values['rgbB'] - (globals.brightnessOffset / 255.0)) - (globals.blueOffset / 255.0));
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
    reset();
  }

  void reset() {
    //reset all modes and data
    _hasChosenMode = false;
    _displayCheckButton = false;
    _swatches = [];
    _swatchIcons = [];
    _orgRed = [];
    _orgGreen = [];
    _orgBlue = [];
    _brightnessOffset = globals.brightnessOffset;
    _redOffset = globals.redOffset;
    _greenOffset = globals.greenOffset;
    _blueOffset = globals.blueOffset;
  }
}
