import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/PaletteDivider.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;

class Main2Screen extends StatefulWidget {
  @override
  Main2ScreenState createState() => Main2ScreenState();
}

class Main2ScreenState extends State<Main2Screen> with ScreenState {
  List<Swatch> _labels = [];
  List<List<int>> _swatches = [];
  Future<Map<SwatchIcon, List<int>>> _swatchesFuture;

  bool _openPaletteDivider = false;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
    _openPaletteDivider = _labels.isEmpty;
  }

  Future<Map<SwatchIcon, List<int>>> _addSwatches() async {
    _swatches.clear();
    List<int> allSwatches = await IO.loadFormatted();
    Map<SwatchIcon, List<int>> returnMap = {};
    for(int i = 0; i < _labels.length; i++) {
      _swatches.add(
        IO.findMany(
          getSimilarColors(
            _labels[i].color,
            _labels[i],
            IO.getMany(allSwatches),
            maxDist: 5,
            getSimilar: false,
            getOpposite: false,
          ),
        ),
      );
      returnMap[SwatchIcon.swatch(_labels[i], showInfoBox: false)] = _swatches[i];
    }
    return returnMap;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if(!_openPaletteDivider) {
      content = Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: <Widget>[
            FlatButton(
              color: theme.primaryColorDark,
              onPressed: () {
                setState(
                  () {
                    _openPaletteDivider = true;
                  }
                );
              },
              child: Text(
                'Choose a Different Palette',
                style: theme.primaryText,
              ),
            ),
            FlatButton(
              color: theme.primaryColorDark,
              onPressed: () {
                onSave(context, _labels);
              },
              child: Text(
                'Save Palette',
                style: theme.primaryText,
              ),
            ),
            Expanded(
              child: MultipleSwatchList(
                addSwatches: _swatchesFuture,
                updateSwatches: (List<List<int>> swatches) { this._swatches = swatches; },
                rowCount: 1,
                showNoColorsFound: true,
                showPlus: false,
                defaultSort: 'Color',
                sort: globals.defaultSortOptions(IO.getMultiple(_swatches), step: 8),
              ),
            ),
          ],
        ),
      );
    } else {
      content = PaletteDivider(
        onEnter: (List<Swatch> swatches) {
          setState(
            () {
              _labels = swatches;
              _openPaletteDivider = false;
              _swatchesFuture = _addSwatches();
            }
          );
        },
      );
    }
    return buildComplete(
      context,
      2,
      content,
      includeHorizontalDragging: !_openPaletteDivider,
    );
  }

  void onSave(BuildContext context, List<Swatch> swatches) {
    globalWidgets.openTwoTextDialog(
      context,
      'Enter a brand and name for this palette:',
      'Brand', 'Palette',
      'You must add a brand.',
      'You must add a palette name.',
      'Save',
      (String brand, String palette) {
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
        }
        IO.add(swatches);
      },
    );
  }

  @override
  void onHorizontalDrag(BuildContext context, DragEndDetails drag) {
    //disable dragging when dragging borders
    if(!_openPaletteDivider) {
      super.onHorizontalDrag(context, drag);
    }
  }
}
