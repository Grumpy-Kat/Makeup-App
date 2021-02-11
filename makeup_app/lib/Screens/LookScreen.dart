import 'package:flutter/material.dart';
import '../Widgets/Look.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/SelectedSwatchPopup.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;
import '../types.dart';
import '../localizationIO.dart';
import 'Screen.dart';

class LookScreen extends StatefulWidget {
  final Look look;
  final int screenId;

  final OnSwatchListAction updateSwatches;

  final String helpText;

  final bool showBack;
  final bool askBackSaved;
  final OnVoidAction onBackPressed;

  final bool showClear;
  final OnVoidAction onClearPressed;

  final bool showAdd;
  final OnVoidAction onAddPressed;

  final bool showSave;
  final OnVoidAction onSavePressed;

  final bool showEdit;
  final bool saveOnEdit;

  LookScreen({ @required this.look, @required this.screenId, @required this.updateSwatches, this.helpText, this.showBack = false, this.askBackSaved = true, this.onBackPressed, this.showClear = false, this.onClearPressed, this.showAdd = false, this.onAddPressed, this.showSave = false, this.onSavePressed, this.showEdit = true, this.saveOnEdit = false });

  @override
  LookScreenState createState() => LookScreenState();
}

class LookScreenState extends State<LookScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>> _swatchesFuture;

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
    Widget leftBar;
    if(widget.showBack) {
      leftBar = buildBack(context);
    }
    List<Widget> rightBar = [];
    if(widget.showClear) {
      rightBar.add(buildClear(context));
    }
    if(widget.showAdd) {
      rightBar.add(buildAdd(context));
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
          widget.helpText,
        ),
      );
    }
    return buildComplete(
      context,
      widget.look.name,
      widget.screenId,
      leftBar: leftBar,
      rightBar: rightBar,
      //scroll view to show all swatches
      body: SingleSwatchList(
        addSwatches: _swatchesFuture,
        updateSwatches: (List<int> swatches) {
          this._swatches = swatches;
          widget.updateSwatches(swatches);
          _hasEdited = true;
        },
        showNoColorsFound: false,
        showPlus: false,
        defaultSort: globals.sort,
        sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 16),
        showDelete: false,
      ),
    );
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
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
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
                widget.onClearPressed();
              },
              () { },
            );
          }
        },
      ),
    );
  }

  Widget buildAdd(BuildContext context) {
    //creates add button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.library_add,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
        ),
        //action determined by screen that uses it
        onPressed: widget.onAddPressed,
      ),
    );
  }

  Widget buildSave(BuildContext context) {
    //creates save button
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
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
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
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
                    insetPadding: EdgeInsets.symmetric(horizontal: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                            widget.updateSwatches(swatches);
                            if(widget.saveOnEdit) {
                              widget.onSavePressed();
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
          widget.onSavePressed();
          widget.onBackPressed();
        },
        () {
          widget.onBackPressed();
        },
      );
    } else {
      widget.onBackPressed();
    }
  }
}
