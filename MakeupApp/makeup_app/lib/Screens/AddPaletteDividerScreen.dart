import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/PaletteDivider.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../allSwatchesIO.dart' as IO;
import '../types.dart';
import '../localizationIO.dart';
import 'Screen.dart';
import 'AddPaletteScreen.dart';

class AddPaletteDividerScreen extends StatefulWidget {
  @override
  AddPaletteDividerScreenState createState() => AddPaletteDividerScreenState();
}

class AddPaletteDividerScreenState extends State<AddPaletteDividerScreen> with ScreenState {
  static bool _isUsingPaletteDivider = true;

  static List<int> _swatches = [];
  static List<SwatchIcon> _swatchIcons = [];

  static List<double> _orgRed = [];
  static List<double> _orgGreen = [];
  static List<double> _orgBlue = [];
  static int _brightnessOffset = 0;
  static int _redOffset = 0;
  static int _greenOffset = 0;
  static int _blueOffset = 0;

  @override
  void initState() {
    super.initState();
    PaletteDividerState.reset();
    for(int i = _swatches.length - 1; i >= 0; i--) {
      Swatch swatch = IO.get(_swatches[i]);
      if(swatch == null) {
        _swatches.removeAt(i);
        _orgRed.removeAt(i);
        _orgGreen.removeAt(i);
        _orgBlue.removeAt(i);
        continue;
      }
      double red = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
      double green = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
      double blue = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
      //might break something, only do it if absolutely necessary
      if(swatch.color.values['rgbR'] != red || swatch.color.values['rgbG'] != green || swatch.color.values['rgbB'] != blue) {
        _orgRed[i] = swatch.color.clampValue(swatch.color.values['rgbR'] - (_redOffset / 255.0) - (_brightnessOffset / 255.0));
        _orgGreen[i] = swatch.color.clampValue(swatch.color.values['rgbG'] - (_greenOffset / 255.0) - (_brightnessOffset / 255.0));
        _orgBlue[i] = swatch.color.clampValue(swatch.color.values['rgbB'] - (_blueOffset / 255.0) - (_brightnessOffset / 255.0));
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
    if(_isUsingPaletteDivider) {
      //using palette divider mode and hasn't finished
      return getPaletteDividerScreen(context);
    } else {
      //using palette divider mode and has finished
      return getPaletteListScreen(context);
    }
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
          //return to mode selection
          navigation.pushReplacement(
            context,
            Offset(-1, 0),
            routes.ScreenRoutes.AddPaletteScreen,
            routes.routes['/addPaletteScreen'](context),
          );
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
        onEnter: (List<Swatch> swatches) { onEnter(context, swatches); },
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
          //return to mode selection
          navigation.pushReplacement(
            context,
            Offset(-1, 0),
            routes.ScreenRoutes.AddPaletteScreen,
            routes.routes['/addPaletteScreen'](context),
          );
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
            (int val) async {
              _brightnessOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                swatches[_swatches[i]] = swatch;
              }
              await IO.editIds(swatches);
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
            (int val) async {
              _redOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                swatches[_swatches[i]] = swatch;
              }
              await IO.editIds(swatches);
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
            (int val) async {
              _greenOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                swatches[_swatches[i]] = swatch;
              }
              await IO.editIds(swatches);
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
            (int val) async {
              _blueOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch swatch = IO.get(_swatches[i]);
                swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                swatches[_swatches[i]] = swatch;
              }
              await IO.editIds(swatches);
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

  void onEnter(BuildContext context, List<Swatch> swatches) {
    AddPaletteScreen.onEnter(
      context,
      (String brand, String palette, double weight, double price) {
        globalWidgets.openLoadingDialog(context);
        //assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          Swatch swatch = swatches[i];
          swatch.brand = brand;
          swatch.palette = palette;
          swatch.weight = double.parse((weight / swatches.length).toStringAsFixed(4));
          swatch.price = double.parse((price / swatches.length).toStringAsFixed(2));
          _orgRed.add(swatch.color.values['rgbR']);
          _orgGreen.add(swatch.color.values['rgbG']);
          _orgBlue.add(swatch.color.values['rgbB']);
          swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
          swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
          swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
        }
        //saves swatches and adds them to final list to display
        IO.add(swatches).then((List<int> val) {
          _swatches = val;
          _addSwatchIcons();
          _isUsingPaletteDivider = false;
          Navigator.pop(context);
          setState(() { });
        });
      }
    );
  }

  void onCheckButton() {
    //return to AllSwatchesScreen
    navigation.pushReplacement(
      context,
      Offset(-1, 0),
      routes.ScreenRoutes.AllSwatchesScreen,
      routes.routes['/allSwatchesScreen'](context),
    );
  }

  static void reset() {
    //reset all modes and data
    _isUsingPaletteDivider = true;
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
