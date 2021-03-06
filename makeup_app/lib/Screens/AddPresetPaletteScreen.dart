import 'package:flutter/material.dart';
import '../Widgets/Palette.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/PresetPaletteList.dart';
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/localizationIO.dart';
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../globalWidgets.dart' as globalWidgets;
import 'Screen.dart';

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
      leftBar: globalWidgets.getBackButton(
        () => navigation.pushReplacement(
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
      leftBar: globalWidgets.getBackButton(
        () {
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
    //return to AllSwatchesScreen
    allSwatchesIO.add(_selectedPalette!.swatches).then((value) => navigation.pushReplacement(
      context,
      const Offset(-1, 0),
      routes.ScreenRoutes.AllSwatchesScreen,
      routes.routes['/allSwatchesScreen']!(context),
    ));
  }

  static void reset() {
    //reset all modes and data
    _selectedPalette = null;
    _swatchIcons = [];
  }
}
