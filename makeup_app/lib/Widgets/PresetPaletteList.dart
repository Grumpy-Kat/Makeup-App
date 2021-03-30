import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../presetPalettesIO.dart' as IO;
import '../localizationIO.dart';
import '../types.dart';
import 'Palette.dart';

class PresetPaletteList extends StatefulWidget {
  final String initialSearch;
  final OnPaletteAction onPaletteSelected;

  PresetPaletteList({ Key key, @required this.onPaletteSelected, this.initialSearch = '' }) : super(key: key);

  @override
  PresetPaletteListState createState() => PresetPaletteListState();
}

class PresetPaletteListState extends State<PresetPaletteList> {
  Future _addPalettesFuture;
  List<Palette> _allPalettes = [];
  List<Palette> _palettes = [];

  String search = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _addPalettesFuture = _addPalettes();
    search = widget.initialSearch;
  }

  Future<List<Palette>> _addPalettes() async {
    if(_allPalettes == null || _allPalettes.length == 0) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            alignment: const Alignment(-1.0, 0.0),
            child: Stack(
              overflow: Overflow.visible,
              children: [
                AnimatedContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  duration: const Duration(milliseconds: 375),
                  width: _isSearching ? MediaQuery.of(context).size.width - 103 : MediaQuery.of(context).size.width - 30,
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                  curve: Curves.easeOut,
                  alignment: const Alignment(-1.0, 0.0),
                  child: TextFormField(
                    initialValue: search,
                    textInputAction: TextInputAction.search,
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
                      hintText: '${getString('search')}...',
                      hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: theme.primaryColorDark,
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 375),
                  top: 0,
                  left: _isSearching ? MediaQuery.of(context).size.width - 110 : MediaQuery.of(context).size.width - 30,
                  curve: Curves.easeOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6.5),
                    width: 100,
                    alignment: const Alignment(1.0, 0.0),
                    child: AnimatedOpacity(
                      opacity: _isSearching ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        child: Text(
                          getString('cancel'),
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
                if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
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
                            widget.onPaletteSelected(_palettes[i]);
                          });
                        },
                        child: Container(
                          height: 64,
                          decoration: (i == _palettes.length - 1) ? decorationLast : decorationNotLast,
                          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          margin: (i == _palettes.length - 1) ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
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
                } else {
                  children.add(
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.all(10),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return ListView(
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
