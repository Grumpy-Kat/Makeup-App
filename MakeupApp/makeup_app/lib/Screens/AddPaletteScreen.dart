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

  static List<int> _swatches = [];
  static List<SwatchIcon> _swatchIcons = [];

  void _addSwatchIcons() {
    _swatchIcons.clear();
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
        'Add Palette',
        10,
        leftBar: IconButton(
          color: theme.iconTextColor,
          icon: Icon(
            Icons.arrow_back,
            size: theme.primaryIconSize,
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
        rightBar: [
          IconButton(
            icon: Icon(
              Icons.help,
              size: 25.0,
              color: theme.iconTextColor,
            ),
            onPressed: () {
              globalWidgets.openDialog(
                context,
                    (BuildContext context) {
                  return globalWidgets.getAlertDialog(
                    context,
                    content: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Text(
                        'Palette Divider allows you to upload a picture and divide the palette into separate swatches. Then, it will automatically finds the colors and finishes for you. It should be used for most shadows and palettes.\n\n'
                            'Custom allows you to input your own swatches, customizing the colors, finishes, and any other information you want to add. It\'s best for adding irregular palettes that would be difficult to divide into columns and rows.',
                        style: theme.primaryTextSecondary,
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: FlatButton(
                          color: theme.accentColor,
                          onPressed: () {
                            //doesn't use navigation because is popping an Dialog
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: theme.accentTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          ),
        ],
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 40, bottom: 20),
              child: Text('Add swatches using: ', style: theme.primaryTextBold),
            ),
            FlatButton.icon(
              icon: Icon(Icons.crop, size: 20, color: theme.iconTextColor),
              label: Text('Palette Divider', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
              onPressed: () {
                setState(() {
                  _isUsingPaletteDivider = true;
                  _hasChosenMode = true;
                });
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.colorize, size: 20, color: theme.iconTextColor),
              label: Text('Custom', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
              onPressed: () {
                onEnter(
                  context,
                  (String brand, String palette) {
                    setState(() {
                      _brand = brand;
                      _palette = palette;
                      _isUsingPaletteDivider = false;
                      _hasChosenMode = true;
                    });
                  }
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
        'Add Palette',
        10,
        leftBar: IconButton(
          color: theme.iconTextColor,
          icon: Icon(
            Icons.arrow_back,
            size: theme.primaryIconSize,
          ),
          onPressed: () {
            setState(() {
              _hasChosenMode = false;
            });
          },
        ),
        rightBar: [
          IconButton(
            icon: Icon(
              Icons.help,
              size: 25.0,
              color: theme.iconTextColor,
            ),
            onPressed: () {
              globalWidgets.openDialog(
                context,
                (BuildContext context) {
                  return globalWidgets.getAlertDialog(
                    context,
                    content: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Text(
                          'First, press the "Add Image" button. You can choose a palette from your saved photos or open the camera. If the palette has nonuniform columns or rows, add it in sections. It is best to take the pictures in bright lighting, preferably near an open window.\n\n'
                          'Then, type in the number of columns and rows in the palette.\n\n'
                          'Next, drag the outer border to fit the palette\'s edges. Drag the inner borders to fit each pans\' edges. It is better to cut off part of the pans than to go too big.\n\n'
                          'Last, press "Save". It will prompt you to add a brand and name for the palette. All the swatches\' colors and finishes will be detected and they will be added to your collection.\n\n'
                          'You\'ll be taken to a screen to look over the added swatches. They will be arranged by the palette\'s rows. You can edit any of their information, leave ratings, or add tags if you wish to.',
                          style: theme.primaryTextSecondary,
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: FlatButton(
                          color: theme.accentColor,
                          onPressed: () {
                            //doesn't use navigation because is popping an Dialog
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: theme.accentTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          ),
        ],
        body: PaletteDivider(
          onEnter: (List<Swatch> swatches) { onEnterPaletteDivider(context, swatches); },
        ),
      );
    }
    //using palette divider, but has finished OR not using palette divider
    if(_hasChosenMode && ((_isUsingPaletteDivider && _displayCheckButton) || !_isUsingPaletteDivider)) {
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
      Widget floatingAction;
      if(!_isUsingPaletteDivider) {
        //column of check and plus button
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
                  IO.add([
                    Swatch(
                      color: RGBColor(0.5, 0.5, 0.5),
                      finish: 'matte',
                      brand: _brand,
                      palette: _palette,
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
        floatingAction = checkButton;
      }
      return buildComplete(
        context,
        'Add Palette',
        10,
        leftBar: IconButton(
          color: theme.iconTextColor,
          icon: Icon(
            Icons.arrow_back,
            size: theme.primaryIconSize,
          ),
          onPressed: () {
            setState(() {
              _hasChosenMode = false;
            });
          },
        ),
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
    //error
    print('Has reached impossible point!');
    return buildComplete(
      context,
      'Add Palette',
      10,
      body: Text(
        'Error',
        style: theme.errorText,
      ),
    );
  }

  void onEnter(BuildContext context, void Function(String, String) onPressed) {
    globalWidgets.openTwoTextDialog(
      context,
      'Enter a brand and name for this palette:',
      'Brand',
      'Palette',
      'You must add a brand.',
      'You must add a palette name.',
      'Save',
       onPressed,
    );
  }

  void onEnterPaletteDivider(BuildContext context, List<Swatch> swatches) {
    onEnter(
      context,
      (String brand, String palette) {
        _brand = brand;
        _palette = palette;
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
        }
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
    _hasChosenMode = false;
    _displayCheckButton = false;
    _swatches = [];
    _swatchIcons = [];
  }
}
