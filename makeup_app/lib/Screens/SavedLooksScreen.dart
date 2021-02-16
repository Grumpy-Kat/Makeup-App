import 'package:flutter/material.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/Look.dart';
import '../Widgets/Filter.dart';
import '../Widgets/SwatchFilterDrawer.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../savedLooksIO.dart' as IO;
import '../allSwatchesIO.dart' as allSwatchesIO;
import '../localizationIO.dart';
import 'Screen.dart';
import 'SavedLookScreen.dart';

class SavedLooksScreen extends StatefulWidget {
  @override
  SavedLooksScreenState createState() => SavedLooksScreenState();
}

class SavedLooksScreenState extends State<SavedLooksScreen> with ScreenState {
  List<Look> _looks = [];
  Future<Map<Text, List<int>>> _swatchesFuture;

  GlobalKey _swatchListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //create future to get all swatches
    _swatchesFuture = _addSwatches();
  }

  Future<Map<Text, List<int>>> _addSwatches() async {
    //gets all saved looks
    _looks = (await IO.loadFormatted()).values.toList();
    Map<Text, List<int>> returnMap = {};
    for(int i = 0; i < _looks.length; i++) {
      //create text for label and add saved look list
      returnMap[Text(_looks[i].name, textAlign: TextAlign.left, style: theme.primaryTextBold)] = _looks[i].swatches;
    }
    //reload for sort
    setState(() {});
    return returnMap;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_savedLooks'),
      1,
      //scroll view to show all look names as labels and looks as horizontal bodies
      body: MultipleSwatchList(
        key: _swatchListKey,
        addSwatches: _swatchesFuture,
        updateSwatches: (List<List<int>> swatches) {
          for(int i = 0; i < swatches.length; i++) {
            _looks[i].swatches = swatches[i];
          }
        },
        rowCount: 1,
        showNoColorsFound: false,
        showNoFilteredColorsFound: true,
        showPlus: false,
        showDeleteFiltered: false,
        defaultSort: globals.sort,
        sort: globals.defaultSortOptions(allSwatchesIO.getMultiple(getAllSwatches()), step: 16),
        onTap: _onTap,
        onDoubleTap: _onTap,
        overrideSwatchOnTap: true,
        onSwatchTap: (int i, int id) { _onTap(i); },
        overrideSwatchOnDoubleTap: true,
        onSwatchDoubleTap: (int i, int id) { _onTap(i); },
        openEndDrawer: openEndDrawer,
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 15, bottom: (MediaQuery.of(context).size.height * 0.1) + 15),
        width: 65,
        height: 65,
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: theme.accentTextColor,
            size: 40.0,
          ),
          onPressed: () {
            globalWidgets.openTextDialog(
              context,
              getString('todayLook_popupInstructions'),
              getString('todayLook_popupError'),
              getString('save'),
              (String name) {
                globalWidgets.openLoadingDialog(context);
                IO.save(Look(id: '', name: name, swatches: [])).then(
                  (String id) {
                    Navigator.pop(context);
                    navigation.push(
                      context,
                      Offset(1, 0),
                      routes.ScreenRoutes.SavedLookScreen,
                      SavedLookScreen(look: Look(id: id, name: name, swatches: [])),
                    );
                  }
                );
              }
            );
          },
        ),
      ),
      //end drawer for swatch filtering
      endDrawer: SwatchFilterDrawer(onDrawerClose: onFilterDrawerClose, swatchListKey: _swatchListKey),
    );
  }

  void onFilterDrawerClose(List<Filter> filters) {
    (_swatchListKey.currentState as MultipleSwatchListState).onFilterDrawerClose(filters);
  }

  void _onTap(int i) {
    //goes to SavedLookScreen for look pressed or double pressed
    navigation.push(
      context,
      Offset(1, 0),
      routes.ScreenRoutes.SavedLookScreen,
      SavedLookScreen(look: _looks[i]),
    );
  }

  List<List<int>> getAllSwatches() {
    List<List<int>> allSwatches = [];
    for(int i = 0; i < _looks.length; i++) {
      allSwatches.add(_looks[i].swatches);
    }
    return allSwatches;
  }
}
