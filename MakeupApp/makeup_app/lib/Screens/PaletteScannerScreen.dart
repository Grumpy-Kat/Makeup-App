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
    //creates future, mostly to not make something null
    _swatchesFuture = _addSwatches();
    //set mode to palette divider
    _openPaletteDivider = _labels.isEmpty;
  }

  Future<Map<SwatchIcon, List<int>>> _addSwatches() async {
    _swatches.clear();
    //gets all swatches
    List<int> allSwatches = await IO.loadFormatted();
    //final list of labels and swatch bodies
    Map<SwatchIcon, List<int>> returnMap = {};
    for(int i = 0; i < _labels.length; i++) {
      _swatches.add(
        //converts swatches to ints
        IO.findMany(
          //gets the similar swatches
          getSimilarColors(
            _labels[i].color,
            _labels[i],
            IO.getMany(allSwatches), //converts swatch ids to swatches
            maxDist: 9,
            getSimilar: false, //only get by color distance, not categories
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
      //has finished using palette divider and displays similar swatches
      return buildComplete(
        context,
        'Palette Scanner',
        3,
        body: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Column(
            children: <Widget>[
              //return to palette divider
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
              //save palette to collection
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
              //scroll view to show all swatches as labels and similar swatches as horizontal bodies
              Expanded(
                child: MultipleSwatchList(
                  addSwatches: _swatchesFuture,
                  updateSwatches: (List<List<int>> swatches) { this._swatches = swatches; },
                  rowCount: 1,
                  showNoColorsFound: true,
                  showPlus: false,
                  defaultSort: globals.sort,
                  sort: globals.defaultSortOptions(IO.getMultiple(_swatches), step: 16),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      //using palette divider
      return buildComplete(
        context,
        'Palette Scanner',
        3,
        //help button
        rightBar: [
          globalWidgets.getHelpBtn(
            context,
            'This screen can be used to compare other palettes to your existing collection. For example, when shopping, you can take a picture of a palette and compare it to your collection to see if you want to buy it. Or when recreating a look, you can find a picture of the original palettes and compare dupes in your collection.\n\n'
            'First, press the "Add Image" button. You can choose a palette from your saved photos or open the camera. If the palette has nonuniform columns or rows, add it in sections. It is best to take the pictures in bright lighting, preferably near an open window\n\n'
            'Then, type in the number of columns and rows in the palette.\n\n'
            'Next, drag the outer border to fit the palette\'s edges. Drag the inner borders to fit each pans\' edges. It is better to cut off part of the pans than to go too big.\n\n'
            'Last, press "Save". All the swatches\' colors and finishes will be detected. You\'ll be taken to a screen to compare each of the palette\'s swatches to your current collection. They will be arranged by the palette\'s rows.',
          ),
        ],
        //palette divider
        body: PaletteDivider(
          onEnter: (List<Swatch> swatches) {
            setState(
              () {
                //sets mode and future
                _labels = swatches;
                _openPaletteDivider = false;
                _swatchesFuture = _addSwatches();
              }
            );
          },
        ),
      );
    }
  }

  void onSave(BuildContext context, List<Swatch> swatches) {
    //open dialog to enter palette name and brand
    globalWidgets.openTwoTextDialog(
      context,
      'Enter a brand and name for this palette:',
      'Brand', 'Palette',
      'You must add a brand.',
      'You must add a palette name.',
      'Save',
      (String brand, String palette) {
        //assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
        }
        //saves swatches
        IO.add(swatches);
      },
    );
  }
}
