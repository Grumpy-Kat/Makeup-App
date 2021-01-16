import 'package:flutter/material.dart';
import '../Widgets/SingleSwatchList.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../allSwatchesIO.dart' as IO;
import '../localizationIO.dart';
import 'Screen.dart';

class AllSwatchesScreen extends StatefulWidget {
  @override
  AllSwatchesScreenState createState() => AllSwatchesScreenState();
}

class AllSwatchesScreenState extends State<AllSwatchesScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>> _swatchesFuture;

  @override
  void initState() {
    super.initState();
    //create future to get all swatches
    _swatchesFuture = _addSwatches();
    //initially globals does not load the correct default swatch sort, so reset when the settings load
    if(!globals.hasLoaded) {
      globals.addHasLoadedListener(() { setState(() {}); });
    }
    addHasLocalizationLoadedListener(() { setState(() {}); });
  }

  Future<List<int>> _addSwatches() async {
    //gets all swatches
    _swatches = await IO.loadFormatted();
    //reloads for sort
    setState(() {});
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      getString('screen_allSwatches', defaultValue: 'All Swatches'),
      0,
      //scroll view to show all swatches
      body: SingleSwatchList(
        addSwatches: _swatchesFuture,
        updateSwatches: (List<int> swatches) { this._swatches = swatches; },
        showNoColorsFound: false,
        showPlus: false,
        defaultSort: globals.sort,
        sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 16),
      ),
      //floating plus button to go to AddPaletteScreen
      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 12.5, bottom: (MediaQuery.of(context).size.height * 0.1) + 12.5),
        width: 75,
        height: 75,
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: theme.accentTextColor,
            size: 45.0,
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
