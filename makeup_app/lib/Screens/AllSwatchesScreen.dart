import 'package:flutter/material.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/Filter.dart';
import '../Widgets/SwatchFilterDrawer.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import 'Screen.dart';

class AllSwatchesScreen extends StatefulWidget {
  @override
  AllSwatchesScreenState createState() => AllSwatchesScreenState();
}

class AllSwatchesScreenState extends State<AllSwatchesScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>>? _swatchesFuture;

  GlobalKey? _swatchListKey = GlobalKey();

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
    setState(() { });
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<int>> swatchesFutureActual = _swatchesFuture!;
    if(_swatchListKey != null && _swatchListKey!.currentWidget != null) {
      swatchesFutureActual = (_swatchListKey!.currentWidget as SingleSwatchList).swatchList.addSwatches as Future<List<int>>;
    }
    return buildComplete(
      context,
      getString('screen_allSwatches', defaultValue: 'All Swatches'),
      0,
      rightBar: [
        globalWidgets.getLoginButton(context),
      ],
      //scroll view to show all swatches
      body: SingleSwatchList(
        key: _swatchListKey,
        addSwatches: swatchesFutureActual,
        orgAddSwatches: _swatchesFuture,
        updateSwatches: (List<int> swatches) { this._swatches = swatches; },
        showNoColorsFound: false,
        showNoFilteredColorsFound: true,
        showSearch: true,
        showPlus: false,
        showDeleteFiltered: true,
        defaultSort: globals.sort,
        sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 16),
        openEndDrawer: openEndDrawer,
      ),
      //floating plus button to go to AddPaletteScreen
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
            navigation.pushReplacement(
              context,
              const Offset(1, 0),
              routes.ScreenRoutes.AddPaletteScreen,
              routes.routes['/addPaletteScreen']!(context),
            );
          },
        ),
      ),
      //end drawer for swatch filtering
      endDrawer: SwatchFilterDrawer(onDrawerClose: onFilterDrawerClose, swatchListKey: _swatchListKey),
    );
  }

  void onFilterDrawerClose(List<Filter> filters) {
    (_swatchListKey!.currentState as SingleSwatchListState).onFilterDrawerClose(filters);
  }
}
