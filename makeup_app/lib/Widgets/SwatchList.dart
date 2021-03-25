import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Filter.dart';
import '../Widgets/EditSwatchPopup.dart';
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

  final bool showSearch;

  final bool showDelete;
  final bool showDeleteFiltered;

  final bool overrideOnTap;
  final Function onTap;

  final bool overrideOnDoubleTap;
  final Function onDoubleTap;

  final bool showEndDrawer;
  final OnVoidAction openEndDrawer;

  SwatchList({ @required this.addSwatches, this.orgAddSwatches, this.selectedSwatches, this.showInfoBox = true, this.showNoColorsFound = false, this.showNoFilteredColorsFound = true, this.showPlus = false, this.onPlusPressed, this.sort, this.defaultSort, this.showSearch = false, this.showDelete = false, this.showDeleteFiltered = false, this.overrideOnTap = false, this.onTap, this.overrideOnDoubleTap = false, this.onDoubleTap, this.showEndDrawer = true, this.openEndDrawer });
}

mixin SwatchListState {
  SwatchList swatchList;

  String currentSort = 'sort_hue';

  GlobalKey searchKey = GlobalKey();
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  String search = '';
  bool isSearching = false;

  List<Filter> filters = [];
  bool canShowBtns = true;

  void init(SwatchList swatchList) {
    this.swatchList = swatchList;
  }

  Widget buildCompleteList(BuildContext context, Widget list) {
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
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int i) {
        if(swatchIcons.length == 0) {
          if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
        }
        if(swatchList.showPlus && swatchIcons.length == i) {
          return Ink(
            decoration: ShapeDecoration(
              color: theme.accentColor,
              shape: const CircleBorder(),
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
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: <Widget>[
          buildSortDropdown(context),
          if(swatchList.showSearch) buildSearchBar(context),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 375),
            left: MediaQuery.of(context).size.width - ((swatchList.showEndDrawer && swatchList.showDeleteFiltered && filters.length > 0 && canShowBtns ? 3 : 1) * (theme.quaternaryIconSize + 15)) - 16,
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if(swatchList.showEndDrawer && swatchList.showDeleteFiltered && filters.length > 0 && canShowBtns) buildEditBtn(context),
                  if(swatchList.showEndDrawer && swatchList.showDeleteFiltered && filters.length > 0 && canShowBtns) buildDeleteBtn(context),
                  if(swatchList.showEndDrawer) buildFilterBtn(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSortDropdown(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: AnimatedOpacity(
        opacity: isSearching ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 15, 0, 15),
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
                      insets: const EdgeInsets.only(bottom: -5),
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
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    int pos = swatchList.showEndDrawer ? (swatchList.showDeleteFiltered && filters.length > 0 && canShowBtns ? 4 : 2) : 1;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 375),
      top: 0,
      left: isSearching ? 16 : MediaQuery.of(context).size.width - (pos * (theme.quaternaryIconSize + 15)) - 32,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        duration: const Duration(milliseconds: 375),
        width: isSearching ? MediaQuery.of(context).size.width - ((pos - 1) * (theme.quaternaryIconSize + 15)) - 32 : theme.quaternaryIconSize + 47,
        alignment: isSearching ? Alignment.centerLeft : Alignment.centerRight,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: isSearching ? BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: theme.primaryColorDark,
        ) : null,
        child: Row(
          children: <Widget>[
            IconButton(
              constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
              icon: Icon(
                Icons.search,
                size: theme.quaternaryIconSize,
                color: theme.tertiaryTextColor,
              ),
              onPressed: () {
                if(!isSearching) {
                  setState(() {
                    isSearching = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) => searchFocusNode.requestFocus());
                }
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(3, 6, 3, 3),
                child: AnimatedOpacity(
                  opacity: isSearching ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextFormField(
                    key: searchKey,
                    textInputAction: TextInputAction.search,
                    focusNode: searchFocusNode,
                    controller: searchController,
                    onChanged: (String value) {
                      search = value;
                      filterAndSearchSwatches();
                    },
                    onFieldSubmitted: (String value) {
                      searchFocusNode.unfocus();
                      if(search != value) {
                        search = value;
                        filterAndSearchSwatches();
                      }
                      if(search == '') {
                        isSearching = false;
                      }
                    },
                    style: theme.primaryTextPrimary,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterBtn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
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

  Widget buildEditBtn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
        color: theme.primaryColor,
        onPressed: () {
          openEditDialog(context);
        },
        icon: Icon(
          Icons.mode_edit,
          size: theme.quaternaryIconSize,
          color: theme.tertiaryTextColor,
          semanticLabel: 'Edit Filtered Swatches',
        ),
      ),
    );
  }

  Widget buildDeleteBtn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.square(theme.quaternaryIconSize + 15)),
        color: theme.primaryColor,
        onPressed: () {
          globalWidgets.openTwoButtonDialog(
            context,
            '${getString('swatchList_popupInstructions')}',
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

  Future<void> openEditDialog(BuildContext context) {
    return globalWidgets.openDialog(
      context,
      (BuildContext context) {
        return Padding(
          padding: EdgeInsets.zero,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 0),
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: EditSwatchPopup(
                onSave: (String brand, String palette, double weight, double price, int rating, List<String> tags) {
                  globalWidgets.openLoadingDialog(context);
                  editSwatches(brand.trim(), palette.trim(), weight, price, rating, tags).then((value) {
                    setState(() {});
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ),
        );
      }
    );
  }

  void onFilterDrawerClose(List<Filter> newFilters) {
    filters = newFilters;
    filterAndSearchSwatches();
  }

  void clearFilters({ bool refilter = true }) {
    filters.clear();
    if(refilter) {
      filterAndSearchSwatches();
    }
  }

  void setState(OnVoidAction func);
  void parentReset() { }

  Future<void> editSwatches(String brand, String palette, double weight, double price, int rating, List<String> tags);
  Future<void> deleteSwatches();
  void sortSwatches(String val);
  void filterSwatches(List<Filter> filters);
  void searchSwatches(String val);
  Future filterAndSearchSwatchesActual();
  Future sortAndFilterSwatchesActual();

  void filterAndSearchSwatches() {
    swatchList.addSwatches = filterAndSearchSwatchesActual();
  }

  void sortAndFilterSwatches() {
    swatchList.addSwatches = sortAndFilterSwatchesActual();
  }
}
