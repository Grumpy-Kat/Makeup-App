import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../Widgets/Filter.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../types.dart';

class SingleSwatchList extends StatefulWidget {
  final OnSwatchListAction updateSwatches;
  final SwatchList swatchList;

  final OnVoidAction? onTap;
  final OnVoidAction? onDoubleTap;

  SingleSwatchList({ Key? key, required Future addSwatches, Future? orgAddSwatches, required this.updateSwatches, List<int>? selectedSwatches, bool showInfoBox = true, bool showNoColorsFound = false, bool showNoFilteredColorsFound = true, bool showPlus = false, OnVoidAction? onPlusPressed, Map<String, OnSortSwatch>? sort, String? defaultSort, bool showSearch = false, bool showDelete = false, bool showDeleteFiltered = false, bool overrideSwatchOnTap = false, OnSwatchAction? onSwatchTap, bool overrideSwatchOnDoubleTap = false, OnSwatchAction? onSwatchDoubleTap, this.onTap, this.onDoubleTap, bool showEndDrawer = true, OnVoidAction? openEndDrawer }) : this.swatchList = SwatchList(
    addSwatches: addSwatches,
    orgAddSwatches: orgAddSwatches ?? addSwatches,
    selectedSwatches: selectedSwatches ?? [],
    showInfoBox: showInfoBox,
    showNoColorsFound: showNoColorsFound,
    showNoFilteredColorsFound: showNoFilteredColorsFound,
    showPlus: showPlus,
    onPlusPressed: onPlusPressed,
    sort: sort,
    defaultSort: defaultSort,
    showSearch: showSearch,
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
  bool _hasSearched = true;

  @override
  void initState() {
    super.initState();
    init(widget.swatchList);
    currentSort = (swatchList.sort!.containsKey(swatchList.defaultSort) ? swatchList.defaultSort : swatchList.sort!.keys.first);
  }

  void _addSwatchIcons() {
    OnSwatchAction? onDelete = !widget.swatchList.showDelete ? null : (int id) {
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
          showCheck: (swatchList.selectedSwatches ?? []).contains(_swatches[i]),
          onDelete: onDelete,
          overrideOnTap: swatchList.overrideOnTap,
          onTap: swatchList.onTap as OnIntAction?,
          overrideOnDoubleTap: swatchList.overrideOnDoubleTap,
          onDoubleTap: swatchList.onDoubleTap as OnIntAction?,
        )
      );
    }
    //reset this value, just in case
    //_shouldChangeOriginalSwatches = true;
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
    } else if(widget.swatchList.showSearch) {
      if(!_hasSearched) {
        sortAndFilterSwatches();
      }
    }
    return buildCompleteList(
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
  Future<void> editSwatches(String? brand, String? palette, double? weight, double? price, int? rating, List<String>? tags) async {
    Map<int, Swatch> editing = {};
    List<Swatch> swatches = IO.getMany(_swatches);
    for(int i = 0; i < _swatches.length; i++) {
      if(brand != null && brand != '') {
        swatches[i].brand = brand.trim();
      }
      if(palette != null && palette != '') {
        swatches[i].palette = palette.trim();
      }
      if(weight != null) {
        swatches[i].weight = weight;
      }
      if(price != null) {
        swatches[i].price = price;
      }
      if(rating != null && rating > 0 && rating <= 10) {
        swatches[i].rating = rating;
      }
      if(tags != null) {
        swatches[i].tags!.addAll(tags);
      }
      editing[swatches[i].id] = swatches[i];
    }
    await IO.editIds(editing);
  }

  @override
  Future<void> deleteSwatches() async {
    await IO.removeIDsMany(_swatches);
  }

  @override
  void sortSwatches(String val) {
    _shouldChangeOriginalSwatches = true;
    widget.swatchList.addSwatches = IO.sort(_allSwatches, (a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort![val]!(swatch, 0)));
    _hasSorted = true;
  }

  @override
  void filterSwatches(List<Filter> filters) {
    _shouldChangeOriginalSwatches = false;
    widget.swatchList.addSwatches = IO.filter(_allSwatches, filters);
    _hasFiltered = true;
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() { }));
  }

  @override
  void searchSwatches(String val) async {
    _shouldChangeOriginalSwatches = false;
    widget.swatchList.addSwatches = IO.search(_allSwatches, val);
    _hasSearched = true;
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() { }));
  }

  @override
  Future<List<int>> filterAndSearchSwatchesActual() async {
    _swatches = await IO.filter(_allSwatches, filters);
    _shouldChangeOriginalSwatches = false;
    _hasFiltered = true;
    _hasSearched = true;
    _swatches = await IO.search(_swatches, search);
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() { }));
    return _swatches;
  }

  @override
  Future<List<int>> sortAndFilterSwatchesActual() async {
    _swatches = await swatchList.orgAddSwatches;
    _swatches = await IO.sort(_swatches, (a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort![currentSort]!(swatch, 0)));
    _allSwatches = _swatches;
    _swatches = await IO.filter(_swatches, filters);
    _shouldChangeOriginalSwatches = false;
    _hasSorted = true;
    _hasFiltered = true;
    _hasSearched = true;
    return await IO.search(_swatches, search);
  }

  @override
  void parentReset() {
    _hasSearched = false;
  }
}
