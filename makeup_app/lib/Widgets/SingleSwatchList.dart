import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../Widgets/Filter.dart';
import '../allSwatchesIO.dart' as IO;
import '../types.dart';

class SingleSwatchList extends StatefulWidget {
  final OnSwatchListAction updateSwatches;
  final SwatchList swatchList;

  final OnVoidAction onTap;
  final OnVoidAction onDoubleTap;

  SingleSwatchList({ Key key, @required Future addSwatches, @required this.updateSwatches, List<int> selectedSwatches, bool showInfoBox = true, bool showNoColorsFound = false, bool showPlus = false, OnVoidAction onPlusPressed, Map<String, OnSortSwatch> sort, String defaultSort, bool showDelete = false, bool overrideSwatchOnTap = false, OnSwatchAction onSwatchTap, bool overrideSwatchOnDoubleTap = false, OnSwatchAction onSwatchDoubleTap, this.onTap, this.onDoubleTap, OnVoidAction openEndDrawer }) : this.swatchList = SwatchList(
    addSwatches: addSwatches,
    selectedSwatches: selectedSwatches ?? [],
    showInfoBox: showInfoBox,
    showNoColorsFound: showNoColorsFound,
    showPlus: showPlus,
    onPlusPressed: onPlusPressed,
    sort: sort,
    defaultSort: defaultSort,
    showDelete: showDelete,
    overrideOnTap: overrideSwatchOnTap,
    onTap: onSwatchTap,
    overrideOnDoubleTap: overrideSwatchOnDoubleTap,
    onDoubleTap: onSwatchDoubleTap,
    openEndDrawer: openEndDrawer,
  ), super(key: key);

  @override
  SingleSwatchListState createState() => SingleSwatchListState();
}

class SingleSwatchListState extends State<SingleSwatchList> with SwatchListState {
  List<int> _allSwatches = [];
  //swatches might be filtered and have less than allSwatches, allSwatches will be cached to prevent having to reload them when filters are removed or changed
  List<int> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];

  bool _shouldChangeOriginalSwatches = true;
  bool _hasSorted = true;
  bool _hasFiltered = true;

  @override
  void initState() {
    super.initState();
    init(widget.swatchList);
    currentSort = (swatchList.sort.containsKey(swatchList.defaultSort) ? swatchList.defaultSort : swatchList.sort.keys.first);
  }

  void _addSwatchIcons() {
    OnSwatchAction onDelete = !widget.swatchList.showDelete ? null : (int id) {
      if(_swatches.contains(id)) {
        _swatches.remove(id);
        widget.updateSwatches(_swatches);
      }
    };
    _swatchIcons.clear();
    for(int i = 0; i < _swatches.length; i++) {
      _swatchIcons.add(
        SwatchIcon.id(
          _swatches[i],
          showInfoBox: widget.swatchList.showInfoBox,
          showCheck: swatchList.selectedSwatches.contains(_swatches[i]),
          onDelete: onDelete,
          overrideOnTap: swatchList.overrideOnTap,
          onTap: swatchList.onTap,
          overrideOnDoubleTap: swatchList.overrideOnDoubleTap,
          onDoubleTap: swatchList.onDoubleTap,
        )
      );
    }
    //reset this value, just in case
    _shouldChangeOriginalSwatches = true;
    _hasSorted = false;
    _hasFiltered = false;
  }

  @override
  Widget build(BuildContext context) {
    init(widget.swatchList);
    if(!_hasSorted && !_hasFiltered) {
      sortAndFilterSwatches();
    }
    return buildComplete(
      context,
      GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: FutureBuilder(
          future: widget.swatchList.addSwatches,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              _swatches = snapshot.data ?? [];
              if(_shouldChangeOriginalSwatches) {
                _allSwatches = _swatches;
              }
              print('${_swatches.length} ${_allSwatches.length}');
              _addSwatchIcons();
            }
            return buildSwatchList(
              context,
              snapshot,
              _swatchIcons,
              axis: Axis.vertical,
              crossAxisCount: 4,
              padding: 20,
              spacing: 30,
            );
          },
        ),
      ),
    );
  }

  @override
  void sortSwatches(String val) {
    _shouldChangeOriginalSwatches = true;
    widget.swatchList.addSwatches = IO.sort(_allSwatches, (a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort[val](swatch, 0)));
    _hasSorted = true;
  }

  @override
  void filterSwatches(List<Filter> filters) {
    _shouldChangeOriginalSwatches = false;
    //this does not work because it causes rebuilds, which resets _shouldChangeOriginalSwatches and changes _allSwatches; figure out how to it properly by sorting filtering after every reload (they're don't use await)
    /*FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }*/
    widget.swatchList.addSwatches = IO.filter(_allSwatches, filters);
    _hasFiltered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() { }));
  }

  @override
  Future<List<int>> sortAndFilterSwatchesActual() async {
    _swatches = await IO.sort(_allSwatches, (a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort[currentSort](swatch, 0)));
    _allSwatches = _swatches;
    _shouldChangeOriginalSwatches = false;
    _hasSorted = true;
    _hasFiltered = true;
    //unnecessary and causes infinite loop because generally called from build()
    //WidgetsBinding.instance.addPostFrameCallback((_) => setState(() { print('setting state'); }));
    return await IO.filter(_allSwatches, filters);
  }
}
