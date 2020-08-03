import 'package:flutter/material.dart' hide HSVColor;
import '../Screens/Screen.dart';
import '../Widgets/ColorPicker.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;

class Main1Screen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  Main1Screen(this.loadFormatted);

  @override
  Main1ScreenState createState() => Main1ScreenState();
}

class Main1ScreenState extends State<Main1Screen> with ScreenState {
  List<Swatch> _swatches = [];
  Future<List<Swatch>> _swatchesFuture;

  GlobalKey _swatchListKey = GlobalKey();

  RGBColor _pickedColor = null;

  Future<List<Swatch>> _addSwatches() async {
    _swatches = await widget.loadFormatted();
    _swatches = getSimilarColors(
      _pickedColor,
      null,
      _swatches,
      maxDist: 17,
      getSimilar: false,
      getOpposite: false,
    );
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      widget.loadFormatted,
      1,
      Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: ColorPicker(
              onEnter: (double hue, double saturation, double value) {
                _pickedColor = HSVtoRGB(HSVColor(hue, saturation, value));
                _swatchesFuture = _addSwatches();
                (_swatchListKey.currentState as SingleSwatchListState).update(_swatchesFuture);
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: SingleSwatchList(
              key: _swatchListKey,
              addSwatches: _swatchesFuture,
              updateSwatches: (List<Swatch> swatches) { this._swatches = swatches; },
              showNoColorsFound: (_pickedColor != null),
              showPlus: false,
              defaultSort: 'Color',
              sort: {
                'Color': (Swatch swatch) { return distanceSort(swatch.color, _pickedColor); },
                'Finish': (Swatch swatch) { return finishSort(swatch, step: 8); },
                'Palette': (Swatch swatch) { return paletteSort(swatch, _swatches, step: 8); },
              },
            ),
          ),
        ],
      ),
    );
  }
}
