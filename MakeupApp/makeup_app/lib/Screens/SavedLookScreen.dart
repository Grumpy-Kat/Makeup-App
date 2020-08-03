import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../Widgets/Swatch.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

class SavedLookScreen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;
  final void Function(int, String, List<Swatch>) save;

  int id;
  String name;
  List<Swatch> swatches;

  //TODO: get saved swatches
  //TODO: get saved name
  //TODO: figure out how to alter save
  SavedLookScreen(this.loadFormatted, this.save, { this.id = -1, this.name = "", this.swatches });

  @override
  SavedLookScreenState createState() => SavedLookScreenState();
}

class SavedLookScreenState extends State<SavedLookScreen>  {
  @override
  Widget build(BuildContext context) {
    return LookScreen(
      loadFormatted: widget.loadFormatted,
      swatches: widget.swatches,
      updateSwatches: (List<Swatch> swatches) {
        setState(() {
          widget..swatches = swatches;
        });
      },
      name: widget.name,
      showBack: true,
      onBackPressed: () {
        widget.save(widget.id, widget.name, widget.swatches);
        Navigator.pop(context);
      },
      showClear: true,
      onClearPressed: () {
        setState(() {
          //TODO: delete it
          widget.swatches = [];
          widget.save(widget.id, widget.name, widget.swatches);
          Navigator.pop(context);
        });
      },
      showAdd: true,
      onAddPressed: () {
        globals.currSwatches.set(globals.currSwatches.currSwatches + widget.swatches);
      },
      showEdit: true,
    );
  }
}
