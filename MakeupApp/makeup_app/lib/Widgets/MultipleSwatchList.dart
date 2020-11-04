import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../allSwatchesIO.dart' as IO;
import '../types.dart';

class MultipleSwatchList extends StatefulWidget {
  final OnDoubleSwatchListAction updateSwatches;
  final SwatchList swatchList;

  final int rowCount;

  final OnSwatchAction onTap;
  final OnSwatchAction onDoubleTap;

  MultipleSwatchList({ Key key, @required Future addSwatches, @required this.updateSwatches, List<int> selectedSwatches, this.rowCount = 1, bool showInfoBox = true, bool showNoColorsFound = false, bool showPlus = false, OnVoidAction onPlusPressed, Map<String, OnSortSwatch> sort, String defaultSort, bool showDelete = false, bool overrideSwatchOnTap = false, void Function(int, int) onSwatchTap, bool overrideSwatchOnDoubleTap = false, void Function(int, int) onSwatchDoubleTap, this.onTap, this.onDoubleTap }) : this.swatchList = SwatchList(
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
  MultipleSwatchListState createState() => MultipleSwatchListState();
}

class MultipleSwatchListState extends State<MultipleSwatchList> with SwatchListState {
  List<List<int>> swatches = [];
  List<List<SwatchIcon>> swatchIcons = [];

  List<Widget> swatchLabels = [];

  void _addSwatchIcons() {
    swatchIcons.clear();
    for(int i = 0; i < swatches.length; i++) {
      swatchIcons.add([]);
      OnSwatchAction onDelete = !widget.swatchList.showDelete ? null : (int id) {
        if(swatches[i].contains(id)) {
          swatches[i].remove(id);
          widget.updateSwatches(swatches);
        }
      };
      for(int j = 0; j < swatches[i].length; j++) {
        swatchIcons[i].add(
          SwatchIcon.id(
            swatches[i][j],
            showInfoBox: widget.swatchList.showInfoBox,
            showCheck: swatchList.selectedSwatches.contains(swatches[i]),
            onDelete: onDelete,
            overrideOnTap: swatchList.overrideOnTap,
            onTap: (int id) { swatchList.onTap(i, id); },
            overrideOnDoubleTap: swatchList.overrideOnDoubleTap,
            onDoubleTap: (int id) { swatchList.onDoubleTap(i, id); },
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    init(widget.swatchList);
    return buildComplete(
      context,
      ListView(
        children: <Widget>[
          FutureBuilder(
            future: widget.swatchList.addSwatches,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List<Widget> column = [];
              if(snapshot.connectionState == ConnectionState.done) {
                swatchLabels = snapshot.data.keys.toList();
                swatches = snapshot.data.values.toList();
                _addSwatchIcons();
                for(int i = 0; i < swatchIcons.length; i++) {
                  List<Widget> innerColumn = [];
                  innerColumn.add(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                        height: (swatchLabels[i] is SwatchIcon ? 80 : 50),
                        child: swatchLabels[i],
                      ),
                    ),
                  );
                  innerColumn.add(
                    Container(
                      height: 80,
                      child: buildSwatchList(
                        context,
                        snapshot,
                        swatchIcons[i],
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
  void sortSwatches(String val) {
    widget.swatchList.addSwatches = IO.sortMultiple(swatchLabels, swatches, widget.swatchList.sort[val]);
  }
}
