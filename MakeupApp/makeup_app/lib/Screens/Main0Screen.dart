import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/SingleSwatchList.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../allSwatchesIO.dart' as IO;

class Main0Screen extends StatefulWidget {
  @override
  Main0ScreenState createState() => Main0ScreenState();
}

class Main0ScreenState extends State<Main0Screen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>> _swatchesFuture;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    _swatches = await IO.loadFormatted();
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      0,
      SingleSwatchList(
        addSwatches: _swatchesFuture,
        updateSwatches: (List<int> swatches) { this._swatches = swatches; },
        showNoColorsFound: false,
        showPlus: false,
        defaultSort: 'Color',
        sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 8),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 12.5, bottom: (MediaQuery.of(context).size.height * 0.1) + 12.5),
        width: 75,
        height: 75,
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: theme.accentTextColor,
            size: 50.0,
          ),
          onPressed: () {
            navigation.pushReplacement(
              context,
              Offset(1, 0),
              routes.ScreenRoutes.AddPaletteScreen,
              routes.routes['/addPaletteScreen'](context),
            );
          },
        ),
      ),
    );
  }
}