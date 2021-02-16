import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Filter.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import '../types.dart';
import '../localizationIO.dart';

class SwatchList {
  Future addSwatches;
  //keep original for when changed with sorting or filtering
  Future orgAddSwatches;

  final List<int> selectedSwatches;

  final bool showInfoBox;

  final bool showNoColorsFound;
  final bool showNoFilteredColorsFound;

  final bool showPlus;
  final OnVoidAction onPlusPressed;

  final Map<String, OnSortSwatch> sort;
  final String defaultSort;

  final bool showDelete;
  final bool showDeleteFiltered;

  final bool overrideOnTap;
  final Function onTap;

  final bool overrideOnDoubleTap;
  final Function onDoubleTap;

  final bool showEndDrawer;
  final OnVoidAction openEndDrawer;

  SwatchList({ @required this.addSwatches, this.orgAddSwatches, this.selectedSwatches, this.showInfoBox = true, this.showNoColorsFound = false, this.showNoFilteredColorsFound = true, this.showPlus = false, this.onPlusPressed, this.sort, this.defaultSort, this.showDelete = false, this.showDeleteFiltered = false, this.overrideOnTap = false, this.onTap, this.overrideOnDoubleTap = false, this.onDoubleTap, this.showEndDrawer = true, this.openEndDrawer });
}

mixin SwatchListState {
  SwatchList swatchList;
  String currentSort = 'sort_hue';
  List<Filter> filters = [];

  void init(SwatchList swatchList) {
    this.swatchList = swatchList;
  }

  Widget buildComplete(BuildContext context, Widget list) {
    return Column(
      children: <Widget>[
        buildOptionsBar(context),
        Expanded(
          child: list,
        ),
      ],
    );
  }

  Widget buildSwatchList(BuildContext context, AsyncSnapshot snapshot, List<SwatchIcon> swatchIcons, { Axis axis = Axis.vertical, int crossAxisCount = 3, double padding = 20, double spacing = 35 }) {
    int itemCount = 0;
    if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
      if(swatchIcons.length == 0 && (swatchList.showNoColorsFound || (swatchList.showNoFilteredColorsFound && filters.length != 0))) {
        //no colors found
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              getString('noColorsFound'),
              style: theme.primaryTextPrimary,
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

  Widget buildOptionsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        buildSortDropdown(context),
        if(swatchList.showEndDrawer) Container(
          margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if(swatchList.showDeleteFiltered && filters.length > 0) buildDeleteBtn(context),
              buildFilterBtn(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSortDropdown(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 0, 15),
      child: Row(
        children: <Widget>[
          Text('${getString('sort_sortBy', defaultValue: 'Sort By')}  ', style: theme.primaryTextQuaternary),
          SizedBox(
            width: 120,
            child: DropdownButton<String>(
              iconSize: theme.quaternaryIconSize,
              isDense: true,
              isExpanded: true,
              style: theme.primaryTextQuaternary,
              iconEnabledColor: theme.tertiaryTextColor,
              onChanged: (String val) {
                setState(() {
                  currentSort = val;
                  sortAndFilterSwatches();
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
              value: currentSort ?? (swatchList.sort.containsKey(swatchList.defaultSort) ? swatchList.defaultSort : swatchList.sort.keys.first),
              items: swatchList.sort.keys.map((String val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text('${getString(val)}', style: theme.primaryTextQuaternary),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterBtn(BuildContext context) {
    return Container(
      //TODO: see if bar and buttons are large enough to comfortably click and see
      margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: IconButton(
        constraints: BoxConstraints.tight(Size.square(theme.quaternaryIconSize + 15)),
        color: theme.primaryColor,
        onPressed: () {
          if(swatchList.openEndDrawer != null) {
            swatchList.openEndDrawer();
          }
        },
        icon: Icon(
          Icons.filter_list_alt,
          size: theme.quaternaryIconSize,
          color: theme.tertiaryTextColor,
          semanticLabel: 'Filter Swatches',
        ),
      ),
    );
  }

  Widget buildDeleteBtn(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: IconButton(
        constraints: BoxConstraints.tight(Size.square(theme.quaternaryIconSize + 15)),
        color: theme.primaryColor,
        onPressed: () {
          //TODO: add proper translation
          globalWidgets.openTwoButtonDialog(
            context,
            'Are you sure you want to delete the currently filtered swatches? They will be permanently deleted and this action is unable to be undone.',
            () {
              globalWidgets.openLoadingDialog(context);
              deleteSwatches().then((value) {
                filters = [];
                sortAndFilterSwatches();
                setState(() { });
                Navigator.pop(context);
              });
            },
            () { },
          );
        },
        icon: Icon(
          Icons.delete,
          size: theme.quaternaryIconSize,
          color: theme.tertiaryTextColor,
          semanticLabel: 'Delete Filtered Swatches',
        ),
      ),
    );
  }

  void onFilterDrawerClose(List<Filter> newFilters) {
    filters = newFilters;
    filterSwatches(filters);
  }

  void setState(OnVoidAction func);

  Future<void> deleteSwatches();
  void sortSwatches(String val);
  void filterSwatches(List<Filter> filters);
  Future sortAndFilterSwatchesActual();

  void sortAndFilterSwatches() {
    swatchList.addSwatches = sortAndFilterSwatchesActual();
  }
}
