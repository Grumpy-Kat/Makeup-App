import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/SelectedSwatchPopup.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;
import '../types.dart';

class LookScreen extends StatefulWidget {
  final List<int> swatches;
  final OnSwatchListAction updateSwatches;

  final String name;

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

  LookScreen({ @required this.swatches, @required this.updateSwatches, @required this.name, this.showBack = false, this.askBackSaved = true, this.onBackPressed, this.showClear = false, this.onClearPressed, this.showAdd = false, this.onAddPressed, this.showSave = false, this.onSavePressed, this.showEdit = true });

  @override
  LookScreenState createState() => LookScreenState();
}

class LookScreenState extends State<LookScreen> with ScreenState {
  List<int> _swatches = [];
  Future<List<int>> _swatchesFuture;

  bool _isEditing = false;
  bool _hasEdited = false;

  @override
  void initState() {
    super.initState();
    //create future to get all swatches
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    //swatches are determined by the screen using it
    _swatches = widget.swatches;
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
    return buildComplete(
      context,
      widget.name,
      10,
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
        showDelete: _isEditing,
      ),
      //if is in edit mode, show floating action button to add or remove swatches
      floatingActionButton: !_isEditing ? null : Container(
        margin: EdgeInsets.only(right: 12.5, bottom: (MediaQuery.of(context).size.height * 0.1) + 12.5),
        width: 75,
        height: 75,
        child: FloatingActionButton(
          heroTag: 'LookScreen Plus',
          child: Icon(
            Icons.add,
            color: theme.accentTextColor,
            size: 50.0,
          ),
          onPressed: () {
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
                            _hasEdited = true;
                          });
                        },
                      ),
                    ),
                  ),
                );
              }
            );
          },
        ),
      ),
    );
  }

  Widget buildBack(BuildContext context) {
    //creates back button
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        color: theme.iconTextColor,
        icon: Icon(
          Icons.arrow_back,
          size: theme.primaryIconSize,
        ),
        onPressed: () {
          onExit();
        },
      ),
    );
  }

  Widget buildClear(BuildContext context) {
    //creates clear button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.iconTextColor,
        icon: Icon(
          Icons.delete,
          size: theme.primaryIconSize,
        ),
        onPressed: () {
          //no need to clear if empty look
          if(_swatches.length > 0) {
            //confirms clearing
            globalWidgets.openTwoButtonDialog(
              context,
              'Are you sure you want to clear the look?',
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
        color: theme.iconTextColor,
        icon: Icon(
          Icons.library_add,
          size: theme.primaryIconSize,
        ),
        //action determined by screen that uses it
        onPressed: widget.onAddPressed,
      ),
    );
  }

  Widget buildSave(BuildContext context) {
    //creates save button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.iconTextColor,
        icon: Icon(
          Icons.save,
          size: theme.primaryIconSize,
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
        color: theme.iconTextColor,
        icon: Icon(
          Icons.mode_edit,
          size: theme.primaryIconSize,
        ),
        onPressed: () {
          setState(() {
            //switches whether in edit mode, which allows user to add or delete swatches from list
            this._isEditing = !this._isEditing;
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
        'Would you like to save?',
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
