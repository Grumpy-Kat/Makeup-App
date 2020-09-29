import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import '../Widgets/Swatch.dart';
import '../theme.dart' as theme;
import '../types.dart';

class SwatchList {
  Future addSwatches;

  final List<int> selectedSwatches;

  final bool showInfoBox;

  final bool showNoColorsFound;

  final bool showPlus;
  final OnVoidAction onPlusPressed;

  final Map<String, OnSortSwatch> sort;
  final String defaultSort;

  final bool showDelete;

  final bool overrideOnTap;
  final Function onTap;

  final bool overrideOnDoubleTap;
  final Function onDoubleTap;

  SwatchList({ @required this.addSwatches, this.selectedSwatches, this.showInfoBox = true, this.showNoColorsFound = false, this.showPlus = false, this.onPlusPressed, this.sort, this.defaultSort, this.showDelete = false, this.overrideOnTap = false, this.onTap, this.overrideOnDoubleTap = false, this.onDoubleTap });
}

mixin SwatchListState {
  SwatchList swatchList;
  String _currentSort;

  void init(SwatchList swatchList) {
    this.swatchList = swatchList;
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

  Widget buildSwatchList(BuildContext context, AsyncSnapshot snapshot, List<SwatchIcon> swatchIcons, { Axis axis = Axis.vertical, int crossAxisCount = 3, double padding = 20, double spacing = 35 }) {
    int itemCount = 0;
    if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
      if(swatchList.showNoColorsFound && swatchIcons.length == 0) {
        //no colors found
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              'No colors found.',
              style: theme.primaryText,
              maxLines: 1,
            ),
          ),
        );
      } else {
        //check if any swatches are null
        for(int i = swatchIcons.length - 1; i >= 0; i--) {
          if(swatchIcons[i] == null) {
            swatchIcons.remove(i);
          }
        }
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
      padding: EdgeInsets.all(padding),
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
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
          Text('Sort by  ', style: theme.primaryTextSmallest),
          SizedBox(
            width: 110,
            child: DropdownButton<String>(
              isDense: true,
              style: theme.primaryTextSmallest,
              onChanged: (String val) {
                setState(() {
                  _currentSort = val;
                  sortSwatches(val);
                });
              },
              underline: Container(
                decoration: UnderlineTabIndicator(
                  insets: EdgeInsets.only(bottom: -5),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
              ),
              value: _currentSort ?? (swatchList.sort.containsKey(swatchList.defaultSort) ? swatchList.defaultSort : swatchList.sort.keys.first),
              items: swatchList.sort.keys.map((String val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text('$val', style: theme.primaryTextSmallest),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void sortSwatches(String val);
  void setState(OnVoidAction func);
}
