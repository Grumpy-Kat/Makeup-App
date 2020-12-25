import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../navigation.dart' as navigation;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../savedLooksIO.dart' as IO;
import '../localizationIO.dart';

class TodayLookScreen extends StatefulWidget {
  @override
  TodayLookScreenState createState() => TodayLookScreenState();
}

class TodayLookScreenState extends State<TodayLookScreen>  {
  String lookName = '';
  int lookId = -1;

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
  }

  @override
  Widget build(BuildContext context) {
    //utilizes LookScreen for all functionality
    return LookScreen(
      swatches: globals.currSwatches.currSwatches,
      updateSwatches: (List<int> swatches) {
        setState(() {
          globals.currSwatches.set(swatches);
        });
      },
      name: getString('screen_todayLook'),
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
      showAdd: false,
      showSave: true,
      onSavePressed: () {
        //saving for first time, so open dialog for name of the look
        globalWidgets.openTextDialog(
          context,
          getString('todayLook_popupInstructions'),
          getString('todayLook_popupError'),
          getString('save'),
          (String value) {
            setState(() {
              lookName = value;
              IO.save(lookId, lookName, globals.currSwatches.currSwatches).then((value) => lookId = value);
              hasSaved = true;
            });
          }
        );
      },
      showEdit: true,
    );
  }

  void exit() {
    //remove listener to avoid errors
    globals.currSwatches.removeListener(_listenerIndex);
    //return to previous screen
    navigation.pop(context, false);
  }
}
