import 'package:flutter/material.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/PaletteDivider.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;
import '../localizationIO.dart';
import 'Screen.dart';

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
    PaletteDividerState.reset();
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
                color: theme.bgColor,
                shape:  Border.all(
                  color: theme.primaryColorDark,
                  width: 2.0,
                ),
                onPressed: () {
                  setState(
                    () {
                      PaletteDividerState.reset();
                      _openPaletteDivider = true;
                    }
                  );
                },
                child: Text(
                  getString('paletteScanner_chooseDifferent'),
                  style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
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
                int brightnessOffset = globals.brightnessOffset;
                int redOffset = globals.redOffset;
                int greenOffset = globals.greenOffset;
                int blueOffset = globals.blueOffset;
                for(int i = 0; i < swatches.length; i++) {
                  Swatch swatch = swatches[i];
                  swatch.color.values['rgbR'] = swatch.color.clampValue(swatch.color.values['rgbR'] + (redOffset / 255.0) + (brightnessOffset / 255.0));
                  swatch.color.values['rgbG'] = swatch.color.clampValue(swatch.color.values['rgbG'] + (greenOffset / 255.0) + (brightnessOffset / 255.0));
                  swatch.color.values['rgbB'] = swatch.color.clampValue(swatch.color.values['rgbB'] + (blueOffset / 255.0) + (brightnessOffset / 255.0));
                }
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
    globalWidgets.openPaletteTextDialog(
      context,
      getString('paletteScanner_popupInstructions'),
      (String brand, String palette, double weight, double price) {
        //assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          swatches[i].brand = brand;
          swatches[i].palette = palette;
          swatches[i].weight = double.parse((weight / swatches.length).toStringAsFixed(2));
          swatches[i].price = double.parse((price / swatches.length).toStringAsFixed(2));
        }
        //saves swatches
        IO.add(swatches);
      },
    );
  }
}
