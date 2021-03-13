import 'package:flutter/material.dart';
import '../Widgets/Palette.dart';
import '../Widgets/Swatch.dart';
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../allSwatchesIO.dart' as allSwatchesIO;
import '../presetPalettesIO.dart' as IO;
import '../globalWidgets.dart' as globalWidgets;
import '../localizationIO.dart';
import 'Screen.dart';

class AddPresetPaletteScreen extends StatefulWidget {
  @override
  AddPresetPaletteScreenState createState() => AddPresetPaletteScreenState();
}

class AddPresetPaletteScreenState extends State<AddPresetPaletteScreen> with ScreenState {
  static List<Palette> _palettes = [];
  static Palette _seletedPalette = null;
  static List<SwatchIcon> _swatchIcons = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Palette>> _addPalettes() async {
    Map<String, Palette> map = (await IO.loadFormatted());
    _palettes = map.values.toList() ?? [];
    return _palettes;
  }

  void _addSwatchIcons() {
    _swatchIcons = [];
    if(_seletedPalette == null) {
      return;
    }
    //create icon widgets for all swatch data
    for(int i = 0; i < _seletedPalette.swatches.length; i++) {
      _swatchIcons.add(
        SwatchIcon.swatch(
          _seletedPalette.swatches[i],
          showInfoBox: true,
          showMoreBtnInInfoBox: false,
          showCheck: false,
          onDelete: null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_seletedPalette == null) {
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
          Offset(-1, 0),
          routes.ScreenRoutes.AddPaletteScreen,
          routes.routes['/addPaletteScreen'](context),
        ),
      ),
      body: FutureBuilder(
        future: _addPalettes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = [];
          if(snapshot.connectionState == ConnectionState.done) {
            _palettes = _palettes ?? [];
            Decoration decorationLast = BoxDecoration(
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
            Decoration decorationNotLast = BoxDecoration(
              color: theme.primaryColor,
              border: Border(
                top: BorderSide(
                  color: theme.primaryColorDark,
                ),
              ),
            );
            for(int i = 0; i < _palettes.length; i++) {
              children.add(
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _seletedPalette = _palettes[i];
                      _addSwatchIcons();
                    });
                  },
                  child: Container(
                    height: 64,
                    decoration: (i == _palettes.length - 1) ? decorationLast : decorationNotLast,
                    padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                    margin: (i == _palettes.length - 1) ? EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('${_palettes[i].brand}', style: theme.primaryTextSecondary),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('${_palettes[i].name}', style: theme.primaryTextPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
          return ListView(
            children: children,
          );
        },
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
            _seletedPalette = null;
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
                  child: Text('${getString('swatch_brand')}: ${_seletedPalette.brand}', style: theme.primaryTextPrimary),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_palette')}: ${_seletedPalette.name}', style: theme.primaryTextPrimary),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_weight')}: ${_seletedPalette.weight}', style: theme.primaryTextPrimary),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${getString('swatch_price')}: ${_seletedPalette.price}', style: theme.primaryTextPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              primary: true,
              padding: EdgeInsets.all(20),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
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
    allSwatchesIO.add(_seletedPalette.swatches).then((value) => navigation.pushReplacement(
      context,
      Offset(-1, 0),
      routes.ScreenRoutes.AllSwatchesScreen,
      routes.routes['/allSwatchesScreen'](context),
    ));
  }

  static void reset() {
    //reset all modes and data
    _palettes = [];
    _seletedPalette = null;
    _swatchIcons = [];
  }
}
