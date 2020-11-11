import 'package:GlamKit/Widgets/NoScreenSwipe.dart';
import 'package:flutter/material.dart' hide HSVColor;
import '../Screens/Screen.dart';
import '../Widgets/ColorPicker.dart';
import '../Widgets/SingleSwatchList.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../globals.dart' as globals;
import '../allSwatchesIO.dart' as IO;

class ColorWheelScreen extends StatefulWidget {
  @override
  ColorWheelScreenState createState() => ColorWheelScreenState();
}

class ColorWheelScreenState extends State<ColorWheelScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>> _swatchesFuture;

  GlobalKey _swatchListKey = GlobalKey();

  RGBColor _pickedColor;

  @override
  void initState() {
    super.initState();
    //creates future, mostly to not make something null
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    //if a color wasn't picked yet, do not show any swatches
    if(_pickedColor == null) {
      return [];
    }
    //gets all swatches
    List<int> allSwatches = await IO.loadFormatted();
    //converts swatches to ints
    _swatches = IO.findMany(
      //gets the similar swatches
      getSimilarColors(
        _pickedColor,
        null,
        IO.getMany(allSwatches), //converts swatch ids to swatches
        maxDist: 14,
        getSimilar: false, //only get by color distance, not categories
        getOpposite: false,
      ).keys.toList(),
    );
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      'Color Wheel',
      2,
      body: Column(
        children: <Widget>[
          //color picker
          Expanded(
            flex: 4,
            child: NoScreenSwipe(
              parent: this,
              child: ColorPicker(
                onEnter: (double hue, double saturation, double value) {
                  setState(() {
                    //sets color and future
                    _pickedColor = HSVtoRGB(HSVColor(hue, saturation, value));
                    _swatchesFuture = _addSwatches();
                  });
                },
              ),
            ),
          ),
          //scroll view to show all swatches
          Expanded(
            flex: 4,
            child: SingleSwatchList(
              key: _swatchListKey,
              addSwatches: _swatchesFuture,
              updateSwatches: (List<int> swatches) { this._swatches = swatches; },
              showNoColorsFound: (_pickedColor != null),
              showPlus: false,
              defaultSort: 'Hue',
              sort: globals.distanceSortOptions(IO.getMultiple([_swatches]), _pickedColor, step: 16),
            ),
          ),
        ],
      ),
    );
  }
}
