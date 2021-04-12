import 'package:flutter/material.dart';
import '../Widgets/Look.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/SelectedSwatchPopup.dart';
import '../Widgets/Filter.dart';
import '../Widgets/SwatchFilterDrawer.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../types.dart';
import 'Screen.dart';

class LookScreen extends StatefulWidget {
  final Look look;
  final int screenId;

  final OnSwatchListAction? updateSwatches;

  final String? helpText;

  final bool showBack;
  final bool askBackSaved;
  final OnVoidAction? onBackPressed;

  final bool showClear;
  final OnVoidAction? onClearPressed;

  final bool showClone;
  final OnVoidAction? onClonePressed;

  final bool showSave;
  final OnVoidAction? onSavePressed;

  final bool showEdit;
  final bool saveOnEdit;

  LookScreen({ required this.look, required this.screenId, required this.updateSwatches, this.helpText, this.showBack = false, this.askBackSaved = true, this.onBackPressed, this.showClear = false, this.onClearPressed, this.showClone = false, this.onClonePressed, this.showSave = false, this.onSavePressed, this.showEdit = true, this.saveOnEdit = false });

  @override
  LookScreenState createState() => LookScreenState();
}

class LookScreenState extends State<LookScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>>? _swatchesFuture;

  GlobalKey? _swatchListKey = GlobalKey();

  bool _hasEdited = false;

  @override
  void initState() {
    super.initState();
    //create future to get all swatches
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    //swatches are determined by the screen using it
    _swatches = widget.look.swatches;
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    //checks which buttons are necessary
    Widget? leftBar;
    if(widget.showBack) {
      leftBar = buildBack(context);
    }
    List<Widget>? rightBar = [];
    if(widget.showClear) {
      rightBar.add(buildClear(context));
    }
    if(widget.showClone) {
      rightBar.add(buildClone(context));
    }
    if(widget.showSave) {
      rightBar.add(buildSave(context));
    }
    if(widget.showEdit) {
      rightBar.add(buildEdit(context));
    }
    if(widget.helpText != null) {
      rightBar.add(
        globalWidgets.getHelpBtn(
          context,
          widget.helpText!,
        ),
      );
    }
    Future<List<int>> swatchesFutureActual = _swatchesFuture!;
    if(_swatchListKey != null && _swatchListKey!.currentWidget != null) {
      swatchesFutureActual = (_swatchListKey!.currentWidget as SingleSwatchList).swatchList.addSwatches as Future<List<int>>;
    }
    return buildComplete(
      context,
      widget.look.name,
      widget.screenId,
      leftBar: leftBar,
      rightBar: rightBar,
      //scroll view to show all swatches
      body: SingleSwatchList(
        key: _swatchListKey,
        addSwatches: swatchesFutureActual,
        orgAddSwatches: _swatchesFuture,
        updateSwatches: (List<int> swatches) {
          this._swatches = swatches;
          if(widget.updateSwatches != null) {
            widget.updateSwatches!(swatches);
          }
          _hasEdited = true;
        },
        showNoColorsFound: false,
        showNoFilteredColorsFound: true,
        showPlus: false,
        defaultSort: globals.sort,
        sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 16),
        showDelete: false,
        showDeleteFiltered: false,
        openEndDrawer: openEndDrawer,
      ),
      //end drawer for swatch filtering
      endDrawer: SwatchFilterDrawer(onDrawerClose: onFilterDrawerClose, swatchListKey: _swatchListKey),
    );
  }

  void onFilterDrawerClose(List<Filter> filters) {
    (_swatchListKey!.currentState as SingleSwatchListState).onFilterDrawerClose(filters);
  }

  Widget buildBack(BuildContext context) {
    //creates back button
    return Align(
      alignment: Alignment.centerLeft,
      child: globalWidgets.getBackButton(() => onExit()),
    );
  }

  Widget buildClear(BuildContext context) {
    //creates clear button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.delete,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        onPressed: () {
          //no need to clear if empty look
          if(_swatches.length > 0) {
            //confirms clearing
            globalWidgets.openTwoButtonDialog(
              context,
              getString('lookScreen_clearWarning'),
              () {
                //action determined by screen that uses it
                if(widget.onClearPressed != null) {
                  widget.onClearPressed!();
                }
              },
              () { },
            );
          }
        },
      ),
    );
  }

  Widget buildClone(BuildContext context) {
    //creates clone button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.note_add,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        //action determined by screen that uses it
        onPressed: widget.onClonePressed,
      ),
    );
  }

  Widget buildSave(BuildContext context) {
    //creates save button
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.save,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        //action determined by screen that uses it
        onPressed: widget.onSavePressed,
      ),
    );
  }

  Widget buildEdit(BuildContext context) {
    //creates edit button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.mode_edit,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        onPressed: () {
          setState(() {
            //show popup to add or remove swatches
            globalWidgets.openDialog(
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
                      child: SelectedSwatchPopup(
                        swatches: _swatches,
                        onChange: (List<int> swatches) {
                          _swatches = swatches;
                        },
                        onSave: (List<int> swatches) {
                          setState(() {
                            if(widget.updateSwatches != null) {
                              widget.updateSwatches!(swatches);
                            }
                            if(widget.saveOnEdit) {
                              if(widget.onSavePressed != null) {
                                widget.onSavePressed!();
                              }
                            } else {
                              _hasEdited = true;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              }
            );
          });
        },
      ),
    );
  }

  @override
  void onExit() async {
    super.onExit();
    //ensures that the changes to the look save before exiting
    if(widget.askBackSaved && _hasEdited) {
      await globalWidgets.openTwoButtonDialog(
        context,
        getString('lookScreen_saveWarning'),
        () {
          if(widget.onSavePressed != null) {
            widget.onSavePressed!();
          }
          if(widget.onBackPressed != null) {
            widget.onBackPressed!();
          }
        },
        () {
          if(widget.onBackPressed != null) {
            widget.onBackPressed!();
          }
        },
      );
    } else {
      if(widget.onBackPressed != null) {
        widget.onBackPressed!();
      }
    }
  }
}
