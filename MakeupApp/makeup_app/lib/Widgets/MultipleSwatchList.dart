import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../theme.dart' as theme;

class MultipleSwatchList extends StatefulWidget {
  final void Function(List<List<Swatch>>) updateSwatches;
  SwatchList swatchList;

  final List<SwatchIcon> swatchLabelsIcon;
  final List<Text> swatchLabelsText;

  MultipleSwatchList({ Key key, @required addSwatches, @required this.updateSwatches, showInfoBox = true, showNoColorsFound = false, showPlus = false, onPlusPressed, sort, defaultSort, this.swatchLabelsIcon, this.swatchLabelsText }) : super(key: key) {
    swatchList = SwatchList(
      addSwatches: addSwatches,
      showInfoBox: showInfoBox,
      showNoColorsFound: showNoColorsFound,
      showPlus: showPlus,
      onPlusPressed: onPlusPressed,
      sort: sort,
      defaultSort: defaultSort,
    );
  }
  @override
  MultipleSwatchListState createState() => MultipleSwatchListState();
}

class MultipleSwatchListState extends State<MultipleSwatchList> with SwatchListState {
  List<List<Swatch>> swatches = [];
  List<List<SwatchIcon>> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    init(widget.swatchList);
  }

  void _addSwatchIcons() {
    swatchIcons.clear();
    for(int i = 0; i < swatches.length; i++) {
      swatchIcons.add([]);
      for(int j = 0; j < swatches[i].length; j++) {
        swatchIcons[i].add(SwatchIcon(swatches[i][j], j, showInfoBox: widget.swatchList.showInfoBox));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      FutureBuilder(
        future: widget.swatchList.addSwatches,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            swatches = snapshot.data;
            _addSwatchIcons();
          }
          List<Widget> column = [];
          for(int i = 0; i < swatchIcons.length; i++) {
            List<Widget> row = [];
            if(widget.swatchLabelsIcon != null && widget.swatchLabelsIcon.length > i) {
              row.add(widget.swatchLabelsIcon[i]);
            }
            if(widget.swatchLabelsText != null && widget.swatchLabelsText.length > i) {
              row.add(widget.swatchLabelsText[i]);
            }
            column.add(Row(children: row));
            column.add(buildSwatchList(context, snapshot, swatchIcons[i], Axis.horizontal, 1));
          }
          return Column(
            children: column,
          );
        },
      ),
    );
  }

  @override
  void sortSwatches(String val) {
    for(int i = 0; i < swatches.length; i++) {
      swatches[i].sort((a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort[val](swatch)));
    }
    widget.updateSwatches(swatches);
  }
}
