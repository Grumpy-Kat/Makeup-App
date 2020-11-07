import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../globals.dart' as globals;
import '../navigation.dart' as navigation;
import '../savedLooksIO.dart' as IO;

class SavedLookScreen extends StatefulWidget {
  static int id;
  static String name;
  static List<int> swatches;

  SavedLookScreen({ int id, String name, List<int> swatches }) {
    if(id == null || id == -1) {
      swatches = IO.swatches['$id|$name'];
    } else {
      SavedLookScreen.id = id;
      SavedLookScreen.name = name;
      SavedLookScreen.swatches = swatches;
    }
  }

  @override
  SavedLookScreenState createState() => SavedLookScreenState();
}

class SavedLookScreenState extends State<SavedLookScreen>  {
  @override
  Widget build(BuildContext context) {
    return LookScreen(
      swatches: SavedLookScreen.swatches,
      updateSwatches: (List<int> swatches) {
        setState(() {
          SavedLookScreen.swatches = swatches;
        });
      },
      name: SavedLookScreen.name,
      showBack: true,
      askBackSaved: true,
      onBackPressed: () {
        navigation.pop(context, false);
      },
      showClear: true,
      onClearPressed: () {
        setState(
          () {
            SavedLookScreen.swatches = [];
            IO.save(SavedLookScreen.id, SavedLookScreen.name, SavedLookScreen.swatches);
            navigation.pop(context, true);
          }
        );
      },
      showAdd: true,
      onAddPressed: () {
        globals.currSwatches.addMany(SavedLookScreen.swatches);
      },
      showEdit: true,
      onSavePressed: () {
        IO.save(SavedLookScreen.id, SavedLookScreen.name, SavedLookScreen.swatches);
      },
    );
  }
}
