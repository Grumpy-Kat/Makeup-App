import 'package:flutter/material.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../savedLooksIO.dart' as IO;
import '../allSwatchesIO.dart' as allSwatchesIO;
import 'Screen.dart';
import 'SavedLookScreen.dart';

class SavedLooksScreen extends StatefulWidget {
  @override
  SavedLooksScreenState createState() => SavedLooksScreenState();
}

class SavedLooksScreenState extends State<SavedLooksScreen> with ScreenState {
  List<int> _ids = [];
  List<String> _labels = [];
  List<List<int>> _swatches = [];
  Future<Map<Text, List<int>>> _swatchesFuture;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
  }

  Future<Map<Text, List<int>>> _addSwatches() async {
    Map<String, List<int>> map = await IO.loadFormatted();
    _labels = map.keys.toList();
    _swatches = map.values.toList();
    Map<Text, List<int>> returnMap = {};
    for(int i = 0; i < _labels.length; i++) {
      String label = _labels[i];
      List<String> labelSplit = label.split('|');
      _ids.add(int.parse(labelSplit[0]));
      label = label.substring(labelSplit[0].length + 1);
      returnMap[Text(label, textAlign: TextAlign.left, style: theme.primaryTextBold)] = _swatches[i];
      _labels[i] = label;
    }
    //reloads for sort
    setState(() {});
    return returnMap;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      'Saved Looks',
      1,
      [],
      MultipleSwatchList(
        addSwatches: _swatchesFuture,
        updateSwatches: (List<List<int>> swatches) { this._swatches = swatches; },
        rowCount: 1,
        showNoColorsFound: false,
        showPlus: false,
        defaultSort: 'Color',
        sort: globals.defaultSortOptions(allSwatchesIO.getMultiple(_swatches), step: 16),
        onTap: _onTap,
        onDoubleTap: _onTap,
        overrideSwatchOnTap: true,
        onSwatchTap: (int i, int id) { _onTap(i); },
        overrideSwatchOnDoubleTap: true,
        onSwatchDoubleTap: (int i, int id) { _onTap(i); },
      ),
    );
  }

  void _onTap(int i) {
    navigation.push(
      context,
      Offset(1, 0),
      routes.ScreenRoutes.SavedLookScreen,
      SavedLookScreen(id: _ids[i], name: _labels[i], swatches: _swatches[i]),
    );
  }
}
