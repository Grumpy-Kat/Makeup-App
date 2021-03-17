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
  Future _addPalettesFuture;
  static List<Palette> _allPalettes = [];
  static List<Palette> _palettes = [];
  static Palette _seletedPalette = null;
  static List<SwatchIcon> _swatchIcons = [];

  String search = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _addPalettesFuture = _addPalettes();
  }

  Future<List<Palette>> _addPalettes() async {
    if(_palettes == null || _palettes.length == 0) {
      Map<String, Palette> map = (await IO.loadFormatted());
      _allPalettes = map.values.toList() ?? [];
      _palettes = _allPalettes;
    }
    if(search != '') {
      _palettes = await IO.search(search);
    } else {
      _palettes = _allPalettes;
    }
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.focusedChild.unfocus();
          }
          setState(() {
            _isSearching = false;
          });
        },
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment(-1.0, 0.0),
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  AnimatedContainer(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: Duration(milliseconds: 375),
                    width: _isSearching ? MediaQuery.of(context).size.width - 103 : MediaQuery.of(context).size.width - 30,
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                    curve: Curves.easeOut,
                    alignment: Alignment(-1.0, 0.0),
                    child: TextFormField(
                      initialValue: search,
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          search = value;
                          _addPalettesFuture = _addPalettes();
                        });
                      },
                      style: theme.primaryTextPrimary,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        icon: Icon(
                          Icons.search,
                          color: theme.tertiaryTextColor,
                          size: theme.secondaryIconSize,
                        ),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                      ),
                    ),
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: theme.primaryColorDark,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 375),
                    top: 0,
                    left: _isSearching ? MediaQuery.of(context).size.width - 110 : MediaQuery.of(context).size.width - 30,
                    curve: Curves.easeOut,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6.5),
                      width: 100,
                      alignment: Alignment(1.0, 0.0),
                      child: AnimatedOpacity(
                        opacity: _isSearching ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 200),
                        child: TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                          ),
                          onPressed: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                              currentFocus.focusedChild.unfocus();
                            }
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _addPalettesFuture,
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
            ),
          ],
        ),
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
