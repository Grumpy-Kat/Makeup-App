import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../theme.dart' as theme;

class SingleSwatchList extends StatefulWidget {
  final void Function(List<Swatch>) updateSwatches;
  SwatchList swatchList;

  SingleSwatchList({ Key key, @required addSwatches, @required this.updateSwatches, showInfoBox = true, showNoColorsFound = false, showPlus = false, onPlusPressed, sort, defaultSort}) : super(key: key) {
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
  SingleSwatchListState createState() => SingleSwatchListState();
}

class SingleSwatchListState extends State<SingleSwatchList> with SwatchListState {
  List<Swatch> swatches = [];
  List<SwatchIcon> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    init(widget.swatchList);
  }

  void _addSwatchIcons() {
    swatchIcons.clear();
    for(int i = 0; i < swatches.length; i++) {
      swatchIcons.add(SwatchIcon(swatches[i], i, showInfoBox: widget.swatchList.showInfoBox));
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
          return buildSwatchList(context, snapshot, swatchIcons, Axis.vertical, 3);
        },
      ),
    );
  }

  @override
  void sortSwatches(String val) {
    swatches.sort((a, b) => a.compareTo(b, (swatch) => widget.swatchList.sort[val](swatch)));
    widget.updateSwatches(swatches);
  }
}
