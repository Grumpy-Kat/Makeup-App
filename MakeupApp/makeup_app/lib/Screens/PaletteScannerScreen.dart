import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/PaletteDivider.dart';
import '../Widgets/NoScreenSwipe.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;

class PaletteScannerScreen extends StatefulWidget {
  @override
  PaletteScannerScreenState createState() => PaletteScannerScreenState();
}

class PaletteScannerScreenState extends State<PaletteScannerScreen> with ScreenState {
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
            maxDist: 9,
            getSimilar: false,
            getOpposite: false,
          ).keys.toList(),
        ),
      );
      returnMap[SwatchIcon.swatch(_labels[i], showInfoBox: false)] = _swatches[i];
    }
    return returnMap;
  }

  @override
  Widget build(BuildContext context) {
    if(!_openPaletteDivider) {
      return buildComplete(
        context,
        2,
        Padding(
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
                  style: theme.primaryTextPrimary,
                ),
              ),
              FlatButton(
                color: theme.primaryColorDark,
                onPressed: () {
                  onSave(context, _labels);
                },
                child: Text(
                  'Save Palette',
                  style: theme.primaryTextPrimary,
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
                  sort: globals.defaultSortOptions(IO.getMultiple(_swatches), step: 16),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return buildComplete(
        context,
        3,
        NoScreenSwipe(
          parent: this,
          child: PaletteDivider(
            onEnter: (List<Swatch> swatches) {
              setState(
                () {
                  _labels = swatches;
                  _openPaletteDivider = false;
                  _swatchesFuture = _addSwatches();
                }
              );
            },
            helpText: 'This screen can be used to compare other palettes to your existing collection. For example, when shopping, you can take a picture of a palette and compare it to your collection to see if you want to buy it. Or when recreating a look, you can find a picture of the original palettes and compare dupes in your collection.\n\n'
            'First, press the "Add Image" button. You can choose a palette from your saved photos or open the camera. If the palette has nonuniform columns or rows, add it in sections. It is best to take the pictures in bright lighting, preferably near an open window\n\n'
            'Then, type in the number of columns and rows in the palette.\n\n'
            'Next, drag the outer border to fit the palette\'s edges. Drag the inner borders to fit each pans\' edges. It is better to cut off part of the pans than to go too big.\n\n'
            'Last, press "Save". All the swatches\' colors and finishes will be detected. You\'ll be taken to a screen to compare each of the palette\'s swatches to your current collection. They will be arranged by the palette\'s rows.',
          ),
        ),
      );
    }
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
  void onHorizontalDragStart(BuildContext context, DragStartDetails drag) {
    //disable dragging when dragging borders
    if(!_openPaletteDivider) {
      super.onHorizontalDragStart(context, drag);
    } else {
      isDragging = false;
    }
  }
}
