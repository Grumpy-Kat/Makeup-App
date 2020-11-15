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
      helpText: 'This a look you had previously saved. You can press on any swatch for information about it. Press the "More..." button for more extensive information.\n\n'
      'The delete icon in the upper right corner permanently deletes the look. This action can not be undone.\n\n'
      'The add icon in the upper right corner adds all the swatches in this look to Today\'s Look.\n\n'
      'The edit icon in the upper right corner allows you to add or remove swatches. Press the red "X" in the upper right corner of the swatch to remove it from the look. Press the plus button to see your full collection. Tap on any of the swatches to see information on them. Double tap on them to add them to the look. Double tap on them again to remove them from the look.',
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
