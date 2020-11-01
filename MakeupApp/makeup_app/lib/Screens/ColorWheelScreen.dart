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
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    if(_pickedColor == null) {
      return [];
    }
    List<int> allSwatches = await IO.loadFormatted();
    _swatches = IO.findMany(
      getSimilarColors(
        _pickedColor,
        null,
        IO.getMany(allSwatches),
        maxDist: 14,
        getSimilar: false,
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
      [],
      Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: NoScreenSwipe(
              parent: this,
              child: ColorPicker(
                onEnter: (double hue, double saturation, double value) {
                  setState(() {
                    _pickedColor = HSVtoRGB(HSVColor(hue, saturation, value));
                    _swatchesFuture = _addSwatches();
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SingleSwatchList(
              key: _swatchListKey,
              addSwatches: _swatchesFuture,
              updateSwatches: (List<int> swatches) { this._swatches = swatches; },
              showNoColorsFound: (_pickedColor != null),
              showPlus: false,
              defaultSort: 'Color',
              sort: globals.distanceSortOptions(IO.getMultiple([_swatches]), _pickedColor, step: 16),
            ),
          ),
        ],
      ),
    );
  }
}
