import 'package:flutter/material.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/PaletteDivider.dart';
import '../Widgets/PresetPaletteList.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Palette.dart';
import '../Widgets/Filter.dart';
import '../Widgets/SwatchFilterDrawer.dart';
import '../Widgets/ImagePicker.dart';
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

  GlobalKey _swatchListKey = GlobalKey();

  static bool _hasChosenMode = false;
  static bool _isUsingPaletteDivider = true;
  static bool _hasChosenPalette = false;

  @override
  void initState() {
    super.initState();
    PaletteDividerState.reset();
    //creates future, mostly to not make something null
    _swatchesFuture = _addSwatches();
    //set mode to palette divider
    _hasChosenMode = _labels.isNotEmpty;
    ImagePicker.error = '';
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
    if(_hasChosenMode) {
      if(_hasChosenPalette) {
        return getCompareSwatchesScreen(context);
      } else {
        if(_isUsingPaletteDivider) {
          return getPaletteDividerScreen(context);
        } else {
          return getPresetPaletteScreen(context);
        }
      }
    } else {
      return getModePickerScreen(context);
    }
  }

  Widget getModePickerScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_paletteScanner'),
      4,
      body: Column(
        children: <Widget>[
          //text
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 20),
            child: Text('Add palette using: ', style: theme.primaryTextBold),
          ),
          //sets mode to palette divider using gallery
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.image, size: 20, color: theme.iconTextColor),
            label: Text(getString('imagePicker_gallery'), textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              ImagePicker.openGallery(context, setState).then((value) {
                print(ImagePicker.error);
                setState(() {
                  if(ImagePicker.img != null) {
                    _hasChosenMode = true;
                    _isUsingPaletteDivider = true;
                    _hasChosenPalette = false;
                  }
                });
              });
            }
          ),
          const SizedBox(
            height: 7,
          ),
          //sets mode to palette divider using camera
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.camera, size: 20, color: theme.iconTextColor),
            label: Text(getString('imagePicker_camera'), textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              ImagePicker.openCamera(context, setState).then((value) {
                setState(() {
                  if(ImagePicker.img != null) {
                    _hasChosenMode = true;
                    _isUsingPaletteDivider = true;
                    _hasChosenPalette = false;
                  }
                });
              });
            },
          ),
          const SizedBox(
            height: 7,
          ),
          //sets mode to preset palette gallery
          FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            color: theme.primaryColorDark,
            icon: Icon(Icons.list, size: 20, color: theme.iconTextColor),
            label: Text('Preset Palettes', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
            onPressed: () {
              setState(() {
                _hasChosenMode = true;
                _isUsingPaletteDivider = false;
                _hasChosenPalette = false;
              });
            },
          ),
          if(ImagePicker.error != '')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Text(ImagePicker.error, style: theme.errorTextTertiary),
            ),
        ],
      ),
    );
  }

  Widget getPaletteDividerScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_paletteScanner'),
      4,
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
          setState(() {
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
            _hasChosenPalette = true;
            _swatchesFuture = _addSwatches();
          });
        },
      ),
    );
  }

  Widget getPresetPaletteScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_paletteScanner'),
      4,
      //palette divider
      body: PresetPaletteList(
        onPaletteSelected: (Palette palette) {
          setState(() {
            _labels = palette.swatches;
            _hasChosenPalette = true;
            _swatchesFuture = _addSwatches();
          });
        },
      ),
    );
  }

  Widget getCompareSwatchesScreen(BuildContext context) {
    Future<Map<Widget, List<int>>> swatchesFutureActual = _swatchesFuture;
    if(_swatchListKey != null && _swatchListKey.currentWidget != null) {
      swatchesFutureActual = (_swatchListKey.currentWidget as MultipleSwatchList).swatchList.addSwatches;
    }
    return buildComplete(
      context,
      getString('screen_paletteScanner'),
      4,
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          children: <Widget>[
            //return to palette divider
            FlatButton(
              color: theme.bgColor,
              shape: Border.all(
                color: theme.primaryColorDark,
                width: 2.0,
              ),
              onPressed: () {
                setState(
                  () {
                    PaletteDividerState.reset();
                    _hasChosenMode = false;
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
                key: _swatchListKey,
                addSwatches: swatchesFutureActual,
                orgAddSwatches: _swatchesFuture,
                updateSwatches: (List<List<int>> swatches) { this._swatches = swatches; },
                rowCount: 1,
                showNoColorsFound: true,
                showNoFilteredColorsFound: true,
                showPlus: false,
                defaultSort: globals.sort,
                sort: globals.defaultSortOptions(IO.getMultiple(_swatches), step: 16),
                openEndDrawer: openEndDrawer,
              ),
            ),
          ],
        ),
      ),
      //end drawer for swatch filtering
      endDrawer: SwatchFilterDrawer(onDrawerClose: onFilterDrawerClose, swatchListKey: _swatchListKey),
    );
  }

  void onFilterDrawerClose(List<Filter> filters) {
    (_swatchListKey.currentState as MultipleSwatchListState).onFilterDrawerClose(filters);
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
