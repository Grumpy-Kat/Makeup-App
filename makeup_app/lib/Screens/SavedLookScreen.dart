import 'package:flutter/material.dart';
import '../Widgets/Look.dart';
import '../globals.dart' as globals;
import '../navigation.dart' as navigation;
import '../savedLooksIO.dart' as IO;
import '../localizationIO.dart';
import 'LookScreen.dart';

class SavedLookScreen extends StatefulWidget {
  static String id;
  static Look look;

  SavedLookScreen({ Look look }) {
    if(look == null || look.id == null || look.id == '') {
      //if returning to screen, without setting id, load updated swatches
      //most commonly occurs when going back from SwatchScreen
      if(id != null && id != '') {
        look = IO.looks[id];
      }
    } else {
      //sets screen info
      SavedLookScreen.id = look.id;
      SavedLookScreen.look = look;
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
      look: SavedLookScreen.look,
      screenId: 10,
      updateSwatches: (List<int> swatches) {
        setState(() {
          SavedLookScreen.look.swatches = swatches;
        });
      },
      helpText: '${getString('help_savedLook_0')}\n\n'
      '${getString('help_savedLook_1')}\n\n'
      '${getString('help_savedLook_2')}\n\n'
      '${getString('help_savedLook_3')}',
      showBack: true,
      askBackSaved: true,
      onBackPressed: () {
        //return to previous screen, most likely SavedLooksScreen, no need to reload
        navigation.pop(context, false);
      },
      showClear: true,
      onClearPressed: () async {
        //clear swatches
        SavedLookScreen.look.swatches = [];
        await IO.clear(SavedLookScreen.look.id);
        //return to previous screen
        navigation.pop(context, true);
      },
      showAdd: true,
      onAddPressed: () {
        //adds all swatches of saved look to Today's Look
        globals.currSwatches.addMany(SavedLookScreen.look.swatches);
      },
      showEdit: true,
      saveOnEdit: true,
      onSavePressed: () async {
        //save changes
        await IO.save(SavedLookScreen.look);
      },
    );
  }
}
