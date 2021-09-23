import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/ColorPicker.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/Filter.dart';
import '../Widgets/SwatchFilterDrawer.dart';
import '../Widgets/HelpButton.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import 'Screen.dart';

class ColorWheelScreen extends StatefulWidget {
  @override
  ColorWheelScreenState createState() => ColorWheelScreenState();
}

class ColorWheelScreenState extends State<ColorWheelScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>>? _swatchesFuture;

  GlobalKey? _swatchListKey = GlobalKey();

  RGBColor? _pickedColor;

  bool _settingColor = false;

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
        _pickedColor!,
        null,
        IO.getMany(allSwatches), //converts swatch ids to swatches
        maxDist: ((globals.colorWheelDistance > 4) ? globals.colorWheelDistance - 3 : 1),
        getSimilar: false, //only get by color distance, not categories
        getOpposite: false,
      ).keys.toList(),
    );
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<int>> swatchesFutureActual = _swatchesFuture!;
    if(_swatchListKey != null && _swatchListKey!.currentWidget != null) {
      if(!_settingColor) {
        swatchesFutureActual = (_swatchListKey!.currentWidget as SingleSwatchList).swatchList.addSwatches as Future<List<int>>;
      } else {
        _settingColor = false;
      }
    }
    return buildComplete(
      context,
      getString('screen_colorWheel'),
      3,
      //help button
      rightBar: [
        HelpButton(
          text: '${getString('help_colorWheel_0')}\n\n'
          '${getString('help_colorWheel_1')}\n\n'
          '${getString('help_colorWheel_2')}',
        ),
      ],
      body: Column(
        children: <Widget>[
          //color picker
          Expanded(
            flex: 4,
            child: ColorPicker(
              btnText: getString('colorPicker_btn'),
              onEnter: (double hue, double saturation, double value) {
                //sets color and future
                _pickedColor = HSVtoRGB(HSVColor(hue, saturation, value));
                _settingColor = true;
                if(_swatchListKey!.currentState != null) {
                  //no need to refilter because setting state soon
                  (_swatchListKey!.currentState as SingleSwatchListState).clearFilters(refilter: false);
                }
                _swatchesFuture = _addSwatches();
                setState(() { });
              },
            ),
          ),
          //scroll view to show all swatches
          Expanded(
            flex: 4,
            child: SingleSwatchList(
              key: _swatchListKey,
              addSwatches: swatchesFutureActual,
              orgAddSwatches: _swatchesFuture,
              updateSwatches: (List<int> swatches) { this._swatches = swatches; },
              showNoColorsFound: (_pickedColor != null),
              showNoFilteredColorsFound: (_pickedColor != null),
              showPlus: false,
              defaultSort: 'sort_hue',
              sort: globals.distanceSortOptions(IO.getMultiple([_swatches]), _pickedColor, step: 16),
              openEndDrawer: openEndDrawer,
            ),
          ),
        ],
      ),
      //end drawer for swatch filtering
      endDrawer: SwatchFilterDrawer(onDrawerClose: onFilterDrawerClose, swatchListKey: _swatchListKey),
    );
  }

  void onFilterDrawerClose(List<Filter> filters) {
    (_swatchListKey!.currentState as SingleSwatchListState).onFilterDrawerClose(filters);
  }
}
