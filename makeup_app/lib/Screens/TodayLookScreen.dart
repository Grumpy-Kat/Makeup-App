import 'package:flutter/material.dart';
import '../Data/Look.dart';
import '../IO/savedLooksIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../navigation.dart' as navigation;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import 'LookScreen.dart';

class TodayLookScreen extends StatefulWidget {
  @override
  TodayLookScreenState createState() => TodayLookScreenState();
}

class TodayLookScreenState extends State<TodayLookScreen>  {
  late Look look;

  bool hasSaved = false;
  int _listenerIndex = -1;

  @override
  void initState() {
    super.initState();
    //add listener to currSwatches
    _listenerIndex = globals.currSwatches.addListener(
      (swatch) => setState(() { }),
      (swatch) => setState(() { }),
      () => setState(() { }),
    );
    look = Look(id: '', name: getString('screen_todayLook'), swatches: globals.currSwatches.currSwatches);
  }

  @override
  Widget build(BuildContext context) {
    look.swatches = globals.currSwatches.currSwatches;
    //utilizes LookScreen for all functionality
    return LookScreen(
      look: look,
      screenId: 2,
      updateSwatches: (List<int> swatches) {
        setState(() {
          globals.currSwatches.set(swatches);
        });
      },
      helpText: '${getString('help_todayLook_0')}\n\n'
      '${getString('help_todayLook_1')}\n\n'
      '${getString('help_todayLook_2')}\n\n'
      '${getString('help_todayLook_3')}\n\n',
      showBack: true,
      askBackSaved: hasSaved,
      onBackPressed: exit,
      showClear: true,
      onClearPressed: () {
        //clear currSwatches
        globals.currSwatches.set([]);
        exit();
      },
      showClone: false,
      showSave: true,
      onSavePressed: () {
        if(!hasSaved) {
          //saving for first time, so open dialog for name of the look
          globalWidgets.openTextDialog(
            context,
            getString('todayLook_popupInstructions'),
            getString('todayLook_popupError'),
            getString('save'),
            (String value) {
              setState(() {
                look.name = value;
                IO.save(look).then((String value) => look.id = value);
                hasSaved = true;
              });
            }
          );
        } else {
          IO.save(look);
        }
      },
      showEdit: true,
      saveOnEdit: hasSaved,
    );
  }

  void exit() {
    //remove listener to avoid errors
    globals.currSwatches.removeListener(_listenerIndex);
    //return to previous screen
    navigation.pop(context, false);
  }
}
