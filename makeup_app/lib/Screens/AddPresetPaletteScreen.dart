import 'package:flutter/material.dart' hide BackButton;
import '../Data/Palette.dart';
import '../Data/Swatch.dart';
import '../Data/SwatchImage.dart';
import '../Widgets/SwatchIcon.dart';
import '../Widgets/PresetPaletteList.dart';
import '../Widgets/BackButton.dart';
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../IO/localizationIO.dart';
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../globalWidgets.dart' as globalWidgets;
import 'Screen.dart';
import 'AddPaletteScreen.dart';

class AddPresetPaletteScreen extends StatefulWidget {
  final bool reset;

  AddPresetPaletteScreen({ this.reset = false}) {
    if(reset) {
      AddPresetPaletteScreenState.reset();
    }
  }

  @override
  AddPresetPaletteScreenState createState() => AddPresetPaletteScreenState();
}

class AddPresetPaletteScreenState extends State<AddPresetPaletteScreen> with ScreenState {
  static Palette? _selectedPalette;
  static List<SwatchIcon> _swatchIcons = [];

  GlobalKey _paletteListKey = GlobalKey();

  String _search = '';

  void _addSwatchIcons() {
    _swatchIcons = [];
    if(_selectedPalette != null) {
      //create icon widgets for all swatch data
      for(int i = 0; i < _selectedPalette!.swatches.length; i++) {
        _swatchIcons.add(
          SwatchIcon.swatch(
            _selectedPalette!.swatches[i],
            showInfoBox: true,
            showMoreBtnInInfoBox: false,
            showCheck: false,
            onDelete: null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_selectedPalette == null) {
      return getPaletteListScreen(context);
    } else {
      return getSelectedPaletteScreen(context);
    }
  }

  Widget getPaletteListScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      leftBar: BackButton(
        onPressed: () => navigation.pushReplacement(
          context,
          const Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen']!(context),
        ),
      ),
      body: PresetPaletteList(
        key: _paletteListKey,
        initialSearch: _search,
        onPaletteSelected: (Palette palette) {
          setState(() {
            _search = (_paletteListKey.currentState as PresetPaletteListState).search;
            _selectedPalette = palette;
            _addSwatchIcons();
          });
        }
      ),
    );
  }

  Widget getSelectedPaletteScreen(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_addPalette'),
      10,
      leftBar: BackButton(
        onPressed: () {
          setState(() {
            _selectedPalette = null;
          });
        },
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_brand')}: ${_selectedPalette!.brand}', style: theme.primaryTextPrimary),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_palette')}: ${_selectedPalette!.name}', style: theme.primaryTextPrimary),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_weight')}: ${_selectedPalette!.weight}', style: theme.primaryTextPrimary),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_price')}: ${_selectedPalette!.price}', style: theme.primaryTextPrimary),
                ),
              ],
            ),
          ),
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
              itemCount: _swatchIcons.length,
              itemBuilder: (BuildContext context, int i) {
                return _swatchIcons[i];
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

  void onCheckButton() {
    AddPaletteScreen.onEnter(
      context,
      (String brand, String palette, double weight, double price, DateTime? openDate, DateTime? expirationDate, List<SwatchImage> imgs) async {
        globalWidgets.openLoadingDialog(context);
        List<Swatch> swatches = _selectedPalette!.swatches;
        //assign brand and palette to all swatches
        for(int i = 0; i < swatches.length; i++) {
          Swatch swatch = swatches[i];
          swatch.openDate = openDate;
          swatch.expirationDate = expirationDate;
          if(imgs.length == swatches.length) {
            //can't actually save images due to not having swatchId, so just set what the imgIds should be
            swatch.imgIds = ['0'];
          } else {
            swatch.imgIds = [];
            //can't actually save images due to not having swatchId, so just set what the imgIds should be
            for(int j = 0; j < imgs.length; j++) {
              swatch.imgIds!.add('$j');
            }
          }
        }
        //saves swatches
        allSwatchesIO.add(swatches).then((List<int> val) {
          //actually save the images now because got swatch ids
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
              //using updateImg to specifically set id
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
                //using updateImg to specifically set id
                allSwatchesStorageIO.updateImg(swatchImg: img, shouldCompress: true);
              }
            }
          }
          //return to AllSwatchesScreen
          navigation.pushReplacement(
            context,
            const Offset(-1, 0),
            routes.ScreenRoutes.AllSwatchesScreen,
            routes.routes['/allSwatchesScreen']!(context),
          );
        });
      },
      showRequired: false,
      showNums: false,
    );
  }

  static void reset() {
    //reset all modes and data
    _selectedPalette = null;
    _swatchIcons = [];
  }
}
