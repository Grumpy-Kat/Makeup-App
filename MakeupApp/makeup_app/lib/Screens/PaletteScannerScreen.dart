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
import '../localizationIO.dart';

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
        getString('screen_paletteScanner'),
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
                  getString('paletteScanner_chooseDifferent'),
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
                  getString('paletteScanner_savePalette'),
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
        getString('screen_paletteScanner'),
        3,
        //help button
        rightBar: [
          globalWidgets.getHelpBtn(
            context,
            '${getString('help_paletteScanner_0')}\n\n'
            '${getString('help_paletteScanner_1')}\n\n'
            '${getString('help_paletteScanner_2')}\n\n'
            '${getString('help_paletteScanner_3')}\n\n'
            '${getString('help_paletteScanner_4')}\n\n',
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
      getString('paletteScanner_popupInstructions'),
      getString('paletteScanner_brand'),
      getString('paletteScanner_palette'),
      getString('paletteScanner_brandError'),
      getString('paletteScanner_paletteError'),
      getString('save'),
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
