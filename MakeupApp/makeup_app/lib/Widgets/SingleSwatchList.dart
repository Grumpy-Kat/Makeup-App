import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../allSwatchesIO.dart' as IO;
import '../types.dart';

class SingleSwatchList extends StatefulWidget {
  final OnSwatchListAction updateSwatches;
  final SwatchList swatchList;

  final OnVoidAction onTap;
  final OnVoidAction onDoubleTap;

  SingleSwatchList({ Key key, @required Future addSwatches, @required this.updateSwatches, List<int> selectedSwatches, bool showInfoBox = true, bool showNoColorsFound = false, bool showPlus = false, OnVoidAction onPlusPressed, Map<String, OnSortSwatch> sort, String defaultSort, bool showDelete = false, bool overrideSwatchOnTap = false, OnSwatchAction onSwatchTap, bool overrideSwatchOnDoubleTap = false, OnSwatchAction onSwatchDoubleTap, this.onTap, this.onDoubleTap }) : this.swatchList = SwatchList(
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
  ), super(key: key);

  @override
  SingleSwatchListState createState() => SingleSwatchListState();
}

class SingleSwatchListState extends State<SingleSwatchList> with SwatchListState {
  List<int> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];

  @override
  void initState() {
    super.initState();
    init(widget.swatchList);
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
  }

  @override
  Widget build(BuildContext context) {
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
    widget.swatchList.addSwatches = IO.sort(_swatches, (a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort[val](swatch, 0)));
  }
}
