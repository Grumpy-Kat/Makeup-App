import 'package:flutter/material.dart';
import 'SingleSwatchList.dart';
import '../allSwatchesIO.dart' as IO;
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../types.dart';

class SelectedSwatchPopup extends StatefulWidget {
  final List<int> swatches;
  final OnSwatchListAction onChange;
  final OnSwatchListAction onSave;

  const SelectedSwatchPopup({ Key key, @required this.swatches, @required this.onChange, @required this.onSave }) : super(key: key);

  @override
  SelectedSwatchPopupState createState() => SelectedSwatchPopupState();
}

class SelectedSwatchPopupState extends State<SelectedSwatchPopup> {
  Future<List<int>> _swatchesFuture;
  List<int> _allSwatches = [];
  List<int> _selectedSwatches = [];

  @override
  void initState() {
    super.initState();
    _selectedSwatches = widget.swatches;
    _swatchesFuture = _addSwatches();
  }

  Future<List<int>> _addSwatches() async {
    _allSwatches = await IO.loadFormatted();
    return _allSwatches;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget> [
        Expanded(
      child: SingleSwatchList(
            addSwatches: _swatchesFuture,
            updateSwatches: (List<int> swatches) { this._allSwatches = swatches; },
            selectedSwatches: _selectedSwatches,
            showNoColorsFound: false,
            showPlus: false,
            defaultSort: globals.sort,
            sort: globals.defaultSortOptions(IO.getMultiple([_allSwatches]), step: 8),
            overrideSwatchOnDoubleTap: true,
            onSwatchDoubleTap: (int id) {
              setState(() {
                if(_selectedSwatches.contains(id)) {
                  _selectedSwatches.remove(id);
                } else {
                  _selectedSwatches.add(id);
                }
                widget.onChange(_selectedSwatches);
              });
            },
          ),
        ),
        FlatButton(
          color: theme.accentColor,
          onPressed: () {
            widget.onSave(_selectedSwatches);
            Navigator.pop(context);
          },
          child: Text(
            'Save',
            style: theme.accentText,
          ),
        )
      ],
    );
  }
}
