import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/ColorPicker.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/NoScreenSwipe.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;
import '../localizationIO.dart';
import 'Screen.dart';

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
      getString('screen_colorWheel'),
      2,
      //help button
      rightBar: [
        globalWidgets.getHelpBtn(
          context,
            '${getString('help_colorWheel_0')}\n\n'
            '${getString('help_colorWheel_1')}\n\n'
            '${getString('help_colorWheel_2')}',
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
                btnText: getString('colorPicker_btn'),
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
              defaultSort: 'sort_hue',
              sort: globals.distanceSortOptions(IO.getMultiple([_swatches]), _pickedColor, step: 16),
            ),
          ),
        ],
      ),
    );
  }
}
