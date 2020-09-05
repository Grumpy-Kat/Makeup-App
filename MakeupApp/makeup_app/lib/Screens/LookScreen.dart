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
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    _swatches = widget.swatches;
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [];
    if(widget.showBack) {
      row.add(buildBack(context));
    }
    row.add(
      Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Text(widget.name, style: theme.primaryText),
        ),
      ),
    );
    List<Widget> innerRow = [];
    if(widget.showClear) {
      innerRow.add(buildClear(context));
    }
    if(widget.showAdd) {
      innerRow.add(buildAdd(context));
    }
    if(widget.showSave) {
      innerRow.add(buildSave(context));
    }
    if(widget.showEdit) {
      innerRow.add(buildEdit(context));
    }
    row.add(
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: innerRow,
        ),
      ),
    );
    return buildComplete(
      context,
      10,
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row,
          ),
          Expanded(
            child: SingleSwatchList(
              addSwatches: _swatchesFuture,
              updateSwatches: (List<int> swatches) {
                this._swatches = swatches;
                widget.updateSwatches(swatches);
                _hasEdited = true;
              },
              showNoColorsFound: false,
              showPlus: false,
              defaultSort: globals.sort,
              sort: globals.defaultSortOptions(IO.getMultiple([_swatches]), step: 8),
              showDelete: _isEditing,
            ),
          ),
        ],
      ),
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
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
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
        onPressed: () {
          onExit();
        },
      ),
    );
  }

  Widget buildClear(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.delete,
          size: 30.0,
        ),
        onPressed: () {
          if(_swatches.length > 0) {
            globalWidgets.openTwoButtonDialog(
              context,
              'Are you sure you want to clear the look?',
              () {
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
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.library_add,
          size: 30.0,
        ),
        onPressed: widget.onAddPressed,
      ),
    );
  }

  Widget buildSave(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.save,
          size: 30.0,
        ),
        onPressed: widget.onSavePressed,
      ),
    );
  }

  Widget buildEdit(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.mode_edit,
          size: 30.0,
        ),
        onPressed: () {
          setState(() {
            this._isEditing = !this._isEditing;
          });
        },
      ),
    );
  }

  @override
  void onExit() async {
    super.onExit();
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

  @override
  void onHorizontalDrag(BuildContext context, DragEndDetails drag) {
    onExit();
  }
}
