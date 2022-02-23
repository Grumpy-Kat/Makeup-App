import 'package:flutter/material.dart' hide FlatButton, BackButton;
import 'package:flutter/services.dart';
import '../Data/Swatch.dart';
import '../Data/SwatchImage.dart';
import '../Data/Palette.dart';
import '../Widgets/SwatchIcon.dart';
import '../Widgets/PaletteDivider.dart';
import '../Widgets/ImagePicker.dart';
import '../Widgets/FlatButton.dart';
import '../Widgets/BackButton.dart';
import '../Widgets/HelpButton.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../IO/presetPalettesIO.dart' as presetPalettesIO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../types.dart';
import 'Screen.dart';
import 'AddPaletteScreen.dart';

class AddPaletteDividerScreen extends StatefulWidget {
  final bool reset;

  AddPaletteDividerScreen({ this.reset = false}) {
    if(reset) {
      AddPaletteDividerScreenState.reset();
    }
  }

  @override
  AddPaletteDividerScreenState createState() => AddPaletteDividerScreenState();
}

class AddPaletteDividerScreenState extends State<AddPaletteDividerScreen> with ScreenState {
  static bool _isUsingPaletteDivider = true;
  static bool _hasChosenPhoto = false;

  static List<int> _swatches = [];

  static List<double> _orgRed = [];
  static List<double> _orgGreen = [];
  static List<double> _orgBlue = [];
  static int _brightnessOffset = 0;
  static int _redOffset = 0;
  static int _greenOffset = 0;
  static int _blueOffset = 0;

  //doesn't actually contain swatches, just other values
  static Palette? _palette;

  late TextEditingController _brightnessController;
  late TextEditingController _redController;
  late TextEditingController _greenController;
  late TextEditingController _blueController;

  @override
  void initState() {
    super.initState();
    PaletteDividerState.reset();
    for(int i = _swatches.length - 1; i >= 0; i--) {
      Swatch? swatch = IO.get(_swatches[i]);
      if(swatch == null) {
        _swatches.removeAt(i);
        _orgRed.removeAt(i);
        _orgGreen.removeAt(i);
        _orgBlue.removeAt(i);
        continue;
      }
      double red = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
      double green = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
      double blue = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
      //might break something, only do it if absolutely necessary
      if(swatch.color.values['rgbR'] != red || swatch.color.values['rgbG'] != green || swatch.color.values['rgbB'] != blue) {
        _orgRed[i] = swatch.color.clampValue(swatch.color.values['rgbR']! - (_redOffset / 255.0) - (_brightnessOffset / 255.0));
        _orgGreen[i] = swatch.color.clampValue(swatch.color.values['rgbG']! - (_greenOffset / 255.0) - (_brightnessOffset / 255.0));
        _orgBlue[i] = swatch.color.clampValue(swatch.color.values['rgbB']! - (_blueOffset / 255.0) - (_brightnessOffset / 255.0));
      }
    }
    _brightnessController = TextEditingController(text: _brightnessOffset.toString());
    _redController = TextEditingController(text: _redOffset.toString());
    _greenController = TextEditingController(text: _greenOffset.toString());
    _blueController = TextEditingController(text: _blueOffset.toString());
  }

  @override
  Widget build(BuildContext context) {
    if(_isUsingPaletteDivider) {
      if(_hasChosenPhoto) {
        //using palette divider and hasn't chosen photo
        return getPhotoPickerScreen(context);
      } else {
        //using palette divider and has chosen photo
        return getPaletteDividerScreen(context);
      }
    } else {
      //has finished with palette divider
      return getPaletteListScreen(context);
    }
  }

  Widget getPhotoPickerScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      //back button
      leftBar: BackButton(
        onPressed: () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen']!(context),
        ),
      ),
      //help button
      rightBar: [
        HelpButton(
          text: '${getString('help_addPalette_2')}\n\n'
          '${getString('help_addPalette_3')}\n\n'
          '${getString('help_addPalette_4')}\n\n'
          '${getString('help_addPalette_5')}\n\n'
          '${getString('help_addPalette_6')}\n\n',
        ),
      ],
      //palette divider
      body: Container(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: <Widget>[
            FlatButton(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              bgColor: theme.accentColor,
              onPressed: () {
                ImagePicker.error = '';
                ImagePicker.open(context).then(
                  (val) {
                    setState(() {
                      _hasChosenPhoto = true;
                    });
                  }
                );
              },
              child: Text(
                getString('paletteDivider_add'),
                style: theme.accentTextBold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                getString('paletteDivider_warning'),
                style: theme.primaryTextSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPaletteDividerScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      //back button
      leftBar: BackButton(
        onPressed: () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen']!(context),
        ),
      ),
      //help button
      rightBar: [
        HelpButton(
          text: '${getString('help_addPaletteDivider_0')}\n\n'
          '${getString('help_addPaletteDivider_1')}\n\n'
          '${getString('help_addPaletteDivider_2')}\n\n'
          '${getString('help_addPaletteDivider_3')}\n\n'
          '${getString('help_addPaletteDivider_4')}\n\n',
        ),
      ],
      //palette divider
      body: PaletteDivider(
        onEnter: (List<Swatch> swatches) { onEnter(context, swatches); },
        initialImg: ImagePicker.img,
      ),
    );
  }

  Widget getPaletteListScreen(BuildContext context) {
    //height of num fields
    double height = 55;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 7);
    //outer container includes margin if no field below
    EdgeInsets margin = const EdgeInsets.only(bottom: 10);
    //border and color if no field below
    Decoration decoration = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
        bottom: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    //border and color if field below
    Decoration decorationNoBottom = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      //back button
      leftBar: BackButton(
        onPressed: () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen']!(context),
        ),
      ),
      rightBar: [
        //delete button
        Container(
          margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: IconButton(
            constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
            color: theme.primaryColor,
            onPressed: () {
              globalWidgets.openTwoButtonDialog(
                context,
                '${getString('addPaletteDivider_popupInstructions')}',
                () {
                  globalWidgets.openLoadingDialog(context);
                  IO.removeIDsMany(_swatches);
                  Navigator.pop(context);
                  navigation.pushReplacement(
                    context,
                    const Offset(-1, 0),
                    routes.ScreenRoutes.AddPaletteScreen,
                    routes.routes['/addPaletteScreen']!(context),
                  );
                },
                () { },
              );
            },
            icon: Icon(
              Icons.delete,
              size: theme.quaternaryIconSize,
              color: theme.tertiaryTextColor,
              semanticLabel: 'Delete Filtered Swatches',
            ),
          ),
        ),
        //help button
        HelpButton(
          text: '${getString('help_addPaletteList_0')}\n\n'
          '${getString('help_addPaletteList_1')}\n\n'
          '${getString('help_addPaletteList_2_0')}\n'
          '${getString('help_addPaletteList_2_1')}\n'
          '${getString('help_addPaletteList_2_2')}\n'
          '${getString('help_addPaletteList_2_3')}\n'
          '${getString('help_addPaletteList_2_4')}\n'
          '${getString('help_addPaletteList_2_5')}\n\n'
          '${getString('help_addPaletteList_3')}\n\n',
        ),
      ],
      body: Column(
        children: <Widget> [
          //brightness offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_brightness')} ',
            _brightnessOffset,
            _brightnessController,
            (int val) async {
              _brightnessOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch? swatch = IO.get(_swatches[i]);
                if(swatch != null) {
                  swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatches[_swatches[i]] = swatch;
                }
              }
              TextSelection selection =_brightnessController.selection;
              globalWidgets.openLoadingDialog(context);
              await IO.editIds(swatches);
              Navigator.pop(context);
              _brightnessController.selection = selection;
              setState(() { });
            },
          ),
          //red offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_red')} ',
            _redOffset,
            _redController,
            (int val) async {
              _redOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch? swatch = IO.get(_swatches[i]);
                if(swatch != null) {
                  swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatches[_swatches[i]] = swatch;
                }
              }
              TextSelection selection =_redController.selection;
              globalWidgets.openLoadingDialog(context);
              await IO.editIds(swatches);
              Navigator.pop(context);
              _redController.selection = selection;
              setState(() { });
            },
          ),
          //green offset field
          getNumField(
            context,
            height,
            decorationNoBottom,
            padding,
            margin,
            '${getString('settings_photo_green')} ',
            _greenOffset,
            _greenController,
            (int val) async {
              _greenOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch? swatch = IO.get(_swatches[i]);
                if(swatch != null) {
                  swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatches[_swatches[i]] = swatch;
                }
              }
              TextSelection selection =_greenController.selection;
              globalWidgets.openLoadingDialog(context);
              await IO.editIds(swatches);
              Navigator.pop(context);
              _greenController.selection = selection;
              setState(() { });
            },
          ),
          //blue offset field
          getNumField(
            context,
            height,
            decoration,
            padding,
            margin,
            '${getString('settings_photo_blue')} ',
            _blueOffset,
            _blueController,
            (int val) async {
              _blueOffset = val;
              Map<int, Swatch> swatches = {};
              for(int i = 0; i < _swatches.length; i++) {
                Swatch? swatch = IO.get(_swatches[i]);
                if(swatch != null) {
                  swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
                  swatches[_swatches[i]] = swatch;
                }
              }
              TextSelection selection =_blueController.selection;
              globalWidgets.openLoadingDialog(context);
              await IO.editIds(swatches);
              Navigator.pop(context);
              _blueController.selection = selection;
              setState(() { });
            }
          ),
          //scroll view to show all swatches
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              primary: true,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 30,
                crossAxisSpacing: 30,
                crossAxisCount: 4,
              ),
              itemCount: _swatches.length,
              itemBuilder: (BuildContext context, int i) {
                return SwatchIcon.id(
                  _swatches[i],
                  showInfoBox: true,
                  showCheck: false,
                  onDelete: null,
                );
              },
            ),
          ),
        ],
      ),
      //check button to complete
      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 15, bottom: (MediaQuery.of(context).size.height * 0.1) + 15),
        width: 65,
        height: 65,
        child: FloatingActionButton(
          heroTag: 'AddPaletteScreen Check',
          backgroundColor: theme.checkTextColor,
          child: Icon(
            Icons.check,
            size: 40,
            color: theme.accentTextColor,
          ),
          onPressed: onCheckButton,
        ),
      ),
    );
  }

  Widget getNumField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin, String title, int value, TextEditingController controller, OnIntAction onChanged) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 3),
            child: Text(title, style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    filled: false,
                    //fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    onChanged(int.tryParse(val) ?? 0);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onEnter(BuildContext context, List<Swatch> swatches) {
    AddPaletteScreen.onEnter(
      context,
      (String brand, String palette, double weight, double price, DateTime? openDate, DateTime? expirationDate, List<SwatchImage> imgs) async {
        globalWidgets.openLoadingDialog(context);

        _palette = Palette(
          id: '',
          brand: brand,
          name: palette,
          weight: weight,
          price: price,
          openDate: openDate,
          expirationDate: expirationDate,
          swatches: [],
        );

        // Assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          Swatch swatch = swatches[i];
          swatch.brand = brand;
          swatch.palette = palette;
          swatch.weight = double.parse((weight / swatches.length).toStringAsFixed(4));
          swatch.price = double.parse((price / swatches.length).toStringAsFixed(2));
          swatch.openDate = openDate;
          swatch.expirationDate = expirationDate;
          if(imgs.length == swatches.length) {
            // Can't actually save images due to not having swatchId, so just set what the imgIds should be
            swatch.imgIds = ['0'];
          } else {
            swatch.imgIds = [];
            // Can't actually save images due to not having swatchId, so just set what the imgIds should be
            for(int j = 0; j < imgs.length; j++) {
              swatch.imgIds!.add('$j');
            }
          }

          _orgRed.add(swatch.color.values['rgbR']!);
          _orgGreen.add(swatch.color.values['rgbG']!);
          _orgBlue.add(swatch.color.values['rgbB']!);
          swatch.color.values['rgbR'] = swatch.color.clampValue(_orgRed[i] + (_redOffset / 255.0) + (_brightnessOffset / 255.0));
          swatch.color.values['rgbG'] = swatch.color.clampValue(_orgGreen[i] + (_greenOffset / 255.0) + (_brightnessOffset / 255.0));
          swatch.color.values['rgbB'] = swatch.color.clampValue(_orgBlue[i] + (_blueOffset / 255.0) + (_brightnessOffset / 255.0));
        }

        _brightnessController = TextEditingController(text: _brightnessOffset.toString());
        _redController = TextEditingController(text: _redOffset.toString());
        _greenController = TextEditingController(text: _greenOffset.toString());
        _blueController = TextEditingController(text: _blueOffset.toString());

        // Saves swatches and adds them to final list to display
        List<int> val = await IO.add(swatches);

        // Actually save the images now because got swatch ids
        for(int i = 0; i < swatches.length; i++) {
          if(imgs.length == swatches.length) {
            SwatchImage img = SwatchImage(
              bytes: imgs[i].bytes,
              id: '0',
              swatchId: val[i],
              labels: imgs[i].labels,
              width: imgs[i].width,
              height: imgs[i].height,
            );
            // Using updateImg to specifically set id
            allSwatchesStorageIO.updateImg(swatchImg: img, shouldCompress: true);
          } else {
            for(int j = 0; j < imgs.length; j++) {
              SwatchImage img = SwatchImage(
                bytes: imgs[j].bytes,
                id: '$j',
                swatchId: val[i],
                labels: imgs[j].labels,
                width: imgs[j].width,
                height: imgs[j].height,
              );
              // Using updateImg to specifically set id
              allSwatchesStorageIO.updateImg(swatchImg: img, shouldCompress: true);
            }
          }
        }

        _swatches = val;
        _isUsingPaletteDivider = false;
        Navigator.pop(context);
        setState(() { });
      },
    );
  }

  void onCheckButton() {
    globalWidgets.openTwoButtonDialog(
      context,
      getString('addPalette_database'),
      () {
        if(_palette != null) {
          _palette!.swatches = IO.getMany(_swatches);
          presetPalettesIO.save(_palette!);
        }
      },
      () { },
    ).then(
      (value) {
        //return to AllSwatchesScreen
        navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AllSwatchesScreen,
          routes.routes['/allSwatchesScreen']!(context),
        );
      },
    );
  }

  static void reset() {
    //reset all modes and data
    _isUsingPaletteDivider = true;
    _swatches = [];
    _orgRed = [];
    _orgGreen = [];
    _orgBlue = [];
    _brightnessOffset = globals.brightnessOffset;
    _redOffset = globals.redOffset;
    _greenOffset = globals.greenOffset;
    _blueOffset = globals.blueOffset;
  }
}
