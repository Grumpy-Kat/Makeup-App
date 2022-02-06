import 'package:flutter/material.dart';
import '../Data/Look.dart';
import '../IO/savedLooksIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import 'LookScreen.dart';

class SavedLookScreen extends StatefulWidget {
  static String? id;
  static late Look look;

  SavedLookScreen({ Look? look }) {
    if(look == null || look.id == '') {
      //if returning to screen, without setting id, load updated swatches
      //most commonly occurs when going back from SwatchScreen
      if(id != null && id != '') {
        look = IO.looks![id];
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
        globalWidgets.openLoadingDialog(context);
        //clear swatches
        SavedLookScreen.look.swatches = [];
        await IO.clear(SavedLookScreen.look.id);
        Navigator.pop(context);
        //return to previous screen
        navigation.pop(context, true);
      },
      showClone: true,
      onClonePressed: () {
        globalWidgets.openTextDialog(
          context,
          'Enter a name for the cloned look:',
          'You need to enter a name for the cloned look.',
          getString('save'),
          (String value) {
            globalWidgets.openLoadingDialog(context);
            Look clonedLook = Look.copy(SavedLookScreen.look);
            clonedLook.name = value;
            IO.save(clonedLook).then(
              (String value) {
                clonedLook.id = value;
                Navigator.pop(context);
                navigation.pushReplacement(
                  context,
                  const Offset(1, 0),
                  routes.ScreenRoutes.SavedLookScreen,
                  SavedLookScreen(look: clonedLook),
                );
              }
            );
          }
        );
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
