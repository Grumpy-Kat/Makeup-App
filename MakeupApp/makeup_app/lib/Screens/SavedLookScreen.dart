import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../globals.dart' as globals;
import '../navigation.dart' as navigation;
import '../savedLooksIO.dart' as IO;

class SavedLookScreen extends StatefulWidget {
  int id;
  String name;
  List<int> swatches;

  SavedLookScreen({ this.id = -1, this.name = "", this.swatches });

  @override
  SavedLookScreenState createState() => SavedLookScreenState();
}

class SavedLookScreenState extends State<SavedLookScreen>  {
  @override
  Widget build(BuildContext context) {
    return LookScreen(
      swatches: widget.swatches,
      updateSwatches: (List<int> swatches) {
        setState(() {
          widget.swatches = swatches;
        });
      },
      name: widget.name,
      showBack: true,
      askBackSaved: true,
      onBackPressed: () {
        navigation.pop(context, false);
      },
      showClear: true,
      onClearPressed: () {
        setState(
          () {
            widget.swatches = [];
            IO.save(widget.id, widget.name, widget.swatches);
            navigation.pop(context, true);
          }
        );
      },
      showAdd: true,
      onAddPressed: () {
        globals.currSwatches.addMany(widget.swatches);
      },
      showEdit: true,
      onSavePressed: () {
        IO.save(widget.id, widget.name, widget.swatches);
      },
    );
  }
}
