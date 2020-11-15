import 'package:GlamKit/Widgets/NoScreenSwipe.dart';
import 'package:flutter/material.dart' hide HSVColor;
import '../Screens/Screen.dart';
import '../Widgets/ColorPicker.dart';
import '../Widgets/SingleSwatchList.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
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
        maxDist: globals.colorWheelDistance,
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
      //help button
      rightBar: [
        globalWidgets.getHelpBtn(
          context,
          'This screen allows you to find the nearest swatch to the color you choose on a color wheel. This is helpful if you may be copying a face chart or have a specific color in mind.\n\n'
          'To use the color wheel, first drag over the wheel to select the color. The further from the center you go, the more bright and saturated the color is. Then, drag the bar below it to select how dark or light the shade. The color to the right of this shows the final color.\n\n'
          'Press "Find Colors" to find the closest swatches in your collection. Repeat this process until you find a swatch you like.',
        ),
      ],
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
