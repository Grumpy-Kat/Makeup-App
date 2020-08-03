import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;

class LookScreen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  final List<Swatch> swatches;
  final void Function(List<Swatch>) updateSwatches;

  final String name;

  final bool showBack;
  final void Function() onBackPressed;

  final bool showClear;
  final void Function() onClearPressed;

  final bool showAdd;
  final void Function() onAddPressed;

  final bool showSave;
  final void Function() onSavePressed;

  final bool showEdit;

  LookScreen({ @required this.loadFormatted, @required this.swatches, @required this.updateSwatches, @required this.name, this.showBack = false, this.onBackPressed, this.showClear = false, this.onClearPressed, this.showAdd = false, this.onAddPressed, this.showSave = false, this.onSavePressed, this.showEdit = true });

  @override
  LookScreenState createState() => LookScreenState();
}

class LookScreenState extends State<LookScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    List<Widget> row = [];
    if(widget.showBack) {
      row.add(buildBack(context));
    }
    row.add(Text(widget.name, style: theme.primaryText));
    if(widget.showClear) {
      row.add(buildClear(context));
    }
    if(widget.showAdd) {
      row.add(buildAdd(context));
    }
    if(widget.showSave) {
      row.add(buildSave(context));
    }
    if(widget.showEdit) {
      row.add(buildEdit(context));
    }
    return buildComplete(
      context,
      widget.loadFormatted,
      10,
      Column(
        children: <Widget>[
          Row(
            children: row,
          ),
          Expanded(
            child: SingleSwatchList(
              addSwatches: widget.swatches,
              updateSwatches: (List<Swatch> swatches) { },
              showNoColorsFound: false,
              showPlus: false,
              defaultSort: 'Color',
              sort: {
                'Color': (Swatch swatch) { return stepSort(swatch.color, step: 8); },
                'Finish': (Swatch swatch) { return finishSort(swatch, step: 8); },
                'Palette': (Swatch swatch) { return paletteSort(swatch, widget.swatches, step: 8); },
              },
            ),
          ),
        ],
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
          size: 50.0,
        ),
        onPressed: widget.onBackPressed,
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
          size: 50.0,
        ),
        onPressed: widget.onClearPressed,
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
          size: 50.0,
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
          size: 50.0,
        ),
        onPressed: widget.onAddPressed,
      ),
    );
  }

  Widget buildEdit(BuildContext context) {
    //TODO: make this function
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: theme.primaryTextColor,
        icon: Icon(
          Icons.mode_edit,
          size: 50.0,
        ),
        onPressed: () { setState(() {}); },
      ),
    );
  }
}
