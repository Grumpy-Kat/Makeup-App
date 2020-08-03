import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import '../Widgets/Swatch.dart';
import '../theme.dart' as theme;

class SwatchList {
  Future addSwatches;

  final bool showInfoBox;

  final bool showNoColorsFound;

  final bool showPlus;
  final void Function() onPlusPressed;

  final Map<String, List<double> Function(Swatch)> sort;
  final String defaultSort;

  SwatchList({ @required this.addSwatches, this.showInfoBox = true, this.showNoColorsFound = false, this.showPlus = false, this.onPlusPressed, this.sort, this.defaultSort});
}

mixin SwatchListState {
  SwatchList swatchList;
  String _currentSort;

  void init(SwatchList swatchList) {
    this.swatchList = swatchList;
  }

  void update(Future addSwatches) {
    setState(() { swatchList.addSwatches = addSwatches; });
  }

  Widget buildComplete(BuildContext context, Widget list) {
    return Column(
      children: <Widget>[
        buildSortDropdown(context),
        Expanded(
          child: list,
        ),
      ],
    );
  }

  Widget buildSwatchList(BuildContext context, AsyncSnapshot snapshot, List<SwatchIcon> swatchIcons, Axis axis, int crossAxisCount) {
    int itemCount = 0;
    if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
      if(swatchList.showNoColorsFound && swatchIcons.length == 0) {
        //no colors found
        itemCount = 1;
      } else {
        //swatches
        itemCount = swatchIcons.length;
      }
    } else {
      //loading indicator
      itemCount += 1;
    }
    if(swatchList.showPlus) {
      //plus button
      itemCount++;
    }
    return GridView.builder(
      scrollDirection: axis,
      primary: true,
      padding: const EdgeInsets.all(20),
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 35,
          crossAxisSpacing: 35,
          crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int i) {
        if(swatchIcons.length == 0) {
          if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
            );
          }
          if(swatchList.showNoColorsFound) {
            return Text('No colors found!', textAlign: TextAlign.center, style: theme.primaryText);
          }
        }
        if(swatchList.showPlus && swatchIcons.length == i) {
          return Ink(
            decoration: ShapeDecoration(
              color: theme.accentColor,
              shape: CircleBorder(),
            ),
            child: IconButton(
              color: theme.accentTextColor,
              icon: Icon(
                Icons.add,
                size: 50.0,
              ),
              onPressed: swatchList.onPlusPressed,
            ),
          );
        }
        return swatchIcons[i];
      }
    );
  }

  Widget buildSortDropdown(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
      child: Row(
        children: <Widget>[
          Text('Sort by  ', style: theme.primaryTextSmall),
          SizedBox(
            width: 75,
            child: DropdownButtonFormField<String>(
              isDense: true,
              style: theme.primaryTextSmall,
              onChanged: (String val) {
                setState(() {
                  _currentSort = val;
                  sortSwatches(val);
                });
              },
              value: _currentSort ?? (swatchList.sort.containsKey(swatchList.defaultSort) ? swatchList.defaultSort : swatchList.sort.keys.first),
              items: swatchList.sort.keys.map((String val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text('$val', style: theme.primaryTextSmall),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void sortSwatches(String val);
  void setState(void Function() func);
}
