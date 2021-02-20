import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../Widgets/Filter.dart';
import '../allSwatchesIO.dart' as IO;
import '../types.dart';

class MultipleSwatchList extends StatefulWidget {
  final OnDoubleSwatchListAction updateSwatches;
  final SwatchList swatchList;

  final int rowCount;

  final OnSwatchAction onTap;
  final OnSwatchAction onDoubleTap;

  MultipleSwatchList({ Key key, @required Future addSwatches, @required this.updateSwatches, List<int> selectedSwatches, this.rowCount = 1, bool showInfoBox = true, bool showNoColorsFound = false, bool showNoFilteredColorsFound = true, bool showPlus = false, OnVoidAction onPlusPressed, Map<String, OnSortSwatch> sort, String defaultSort, bool showDelete = false, bool showDeleteFiltered = false, bool overrideSwatchOnTap = false, void Function(int, int) onSwatchTap, bool overrideSwatchOnDoubleTap = false, void Function(int, int) onSwatchDoubleTap, this.onTap, this.onDoubleTap, bool showEndDrawer = true, OnVoidAction openEndDrawer }) : this.swatchList = SwatchList(
    addSwatches: addSwatches,
    orgAddSwatches: addSwatches,
    selectedSwatches: selectedSwatches ?? [],
    showInfoBox: showInfoBox,
    showNoColorsFound: showNoColorsFound,
    showNoFilteredColorsFound: showNoFilteredColorsFound,
    showPlus: showPlus,
    onPlusPressed: onPlusPressed,
    sort: sort,
    defaultSort: defaultSort,
    showDelete: showDelete,
    showDeleteFiltered: showDeleteFiltered,
    overrideOnTap: overrideSwatchOnTap,
    onTap: onSwatchTap,
    overrideOnDoubleTap: overrideSwatchOnDoubleTap,
    onDoubleTap: onSwatchDoubleTap,
    showEndDrawer: showEndDrawer,
    openEndDrawer: openEndDrawer,
  ), super(key: key);

  @override
  MultipleSwatchListState createState() => MultipleSwatchListState();
}

class MultipleSwatchListState extends State<MultipleSwatchList> with SwatchListState {
  List<List<int>> _allSwatches = [];
  List<Widget> _allSwatchLabels = [];
  //swatches might be filtered and have less than allSwatches, allSwatches will be cached to prevent having to reload them when filters are removed or changed
  List<List<int>> _swatches = [];
  List<List<SwatchIcon>> _swatchIcons = [];
  List<Widget> _swatchLabels = [];

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
    _swatchIcons.clear();
    for(int i = 0; i < _swatches.length; i++) {
      _swatchIcons.add([]);
      OnSwatchAction onDelete = !widget.swatchList.showDelete ? null : (int id) {
        if(_swatches[i].contains(id)) {
          _swatches[i].remove(id);
          widget.updateSwatches(_swatches);
        }
      };
      for(int j = 0; j < _swatches[i].length; j++) {
        _swatchIcons[i].add(
          SwatchIcon.id(
            _swatches[i][j],
            showInfoBox: widget.swatchList.showInfoBox,
            showCheck: swatchList.selectedSwatches.contains(_swatches[i]),
            onDelete: onDelete,
            overrideOnTap: swatchList.overrideOnTap,
            onTap: (int id) { swatchList.onTap(i, id); },
            overrideOnDoubleTap: swatchList.overrideOnDoubleTap,
            onDoubleTap: (int id) { swatchList.onDoubleTap(i, id); },
          )
        );
      }
    }
    //reset this value, just in case
    _shouldChangeOriginalSwatches = true;
    _hasSorted = false;
    _hasFiltered = false;
  }

  @override
  Widget build(BuildContext context) {
    init(widget.swatchList);
    if(widget.swatchList.showEndDrawer) {
      if(!_hasSorted && !_hasFiltered) {
        sortAndFilterSwatches();
      }
    }
    return buildCompleteList(
      context,
      ListView(
        children: <Widget>[
          FutureBuilder(
            future: widget.swatchList.addSwatches,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List<Widget> column = [];
              if(snapshot.connectionState == ConnectionState.done) {
                _swatchLabels = snapshot.data.keys.toList();
                _swatches = snapshot.data.values.toList();
                if(_shouldChangeOriginalSwatches) {
                  _allSwatchLabels = _swatchLabels;
                  _allSwatches = _swatches;
                }
                _addSwatchIcons();
                for(int i = 0; i < _swatchIcons.length; i++) {
                  List<Widget> innerColumn = [];
                  innerColumn.add(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                        height: (_swatchLabels[i] is SwatchIcon ? 80 : 50),
                        child: _swatchLabels[i],
                      ),
                    ),
                  );
                  innerColumn.add(
                    Container(
                      height: 80,
                      child: buildSwatchList(
                        context,
                        snapshot,
                        _swatchIcons[i],
                        axis: Axis.horizontal,
                        crossAxisCount: widget.rowCount,
                        padding: 20,
                        spacing: 15,
                      ),
                    ),
                  );
                  column.add(
                    GestureDetector(
                      onTap: () { widget.onTap(i); },
                      onDoubleTap: () { widget.onDoubleTap(i); },
                      child: Column(
                        children: innerColumn,
                      ),
                    ),
                  );
                }
              } else {
                column.add(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                      height: 50,
                    ),
                  ),
                );
                column.add(
                  Container(
                    height: 80,
                    child: buildSwatchList(
                      context,
                      snapshot,
                      [],
                      axis: Axis.horizontal,
                      crossAxisCount: widget.rowCount,
                      padding: 20,
                      spacing: 15,
                    ),
                  ),
                );
              }
              return Column(
                children: column,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<void> deleteSwatches() async {
    List<int> delete = [];
    //compress into single list
    for(int i = 0; i < _swatches.length; i++) {
      delete.addAll(_swatches[i]);
    }
    await IO.removeIDsMany(delete);
  }

  @override
  void sortSwatches(String val) {
    _shouldChangeOriginalSwatches = true;
    widget.swatchList.addSwatches = IO.sortMultiple(_allSwatchLabels, _allSwatches, widget.swatchList.sort[val]);
    _hasSorted = true;
  }

  @override
  void filterSwatches(List<Filter> filters) {
    _shouldChangeOriginalSwatches = false;
    widget.swatchList.addSwatches = IO.filterMultiple(_allSwatchLabels, _allSwatches, filters);
    _hasFiltered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Future<Map<Widget, List<int>>> sortAndFilterSwatchesActual() async {
    Map<Widget, List<int>> map = await swatchList.orgAddSwatches;
    _swatchLabels = map.keys.toList();
    _swatches = map.values.toList();
    map = await IO.sortMultiple(_swatchLabels, _swatches, widget.swatchList.sort[currentSort]);
    _swatchLabels = map.keys.toList();
    _swatches = map.values.toList();
    _allSwatches = _swatches;
    _allSwatchLabels = _swatchLabels;
    _shouldChangeOriginalSwatches = false;
    _hasSorted = true;
    _hasFiltered = true;
   return await IO.filterMultiple(_allSwatchLabels, _allSwatches, filters);
  }
}
