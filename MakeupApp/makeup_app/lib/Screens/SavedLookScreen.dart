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
      //if returning to screen, without setting id, load updated swatches
      //most commonly occurs when going back from SwatchScreen
      swatches = IO.swatches['$id|$name'];
    } else {
      //sets look info
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
    //utilizes LookScreen for all functionality
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
        //return to previous screen, most likely SavedLooksScreen, no need to reload
        navigation.pop(context, false);
      },
      showClear: true,
      onClearPressed: () {
        setState(
          () {
            //clear swatches
            SavedLookScreen.swatches = [];
            //save empty swatch, which will not display in SavedLooksScreen, effectively deleting it
            IO.save(SavedLookScreen.id, SavedLookScreen.name, SavedLookScreen.swatches);
            //return to previous screen
            navigation.pop(context, true);
          }
        );
      },
      showAdd: true,
      onAddPressed: () {
        //adds all swatches of saved look to Today's Look
        globals.currSwatches.addMany(SavedLookScreen.swatches);
      },
      showEdit: true,
      onSavePressed: () {
        //save changes
        IO.save(SavedLookScreen.id, SavedLookScreen.name, SavedLookScreen.swatches);
      },
    );
  }
}
