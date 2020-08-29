import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../navigation.dart' as navigation;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../savedLooksIO.dart' as IO;

class TodayLookScreen extends StatefulWidget {
  @override
  TodayLookScreenState createState() => TodayLookScreenState();
}

class TodayLookScreenState extends State<TodayLookScreen>  {
  String lookName = "";
  int lookId = -1;

  bool hasSaved = false;
  int _listenerIndex = -1;

  @override
  void initState() {
    super.initState();
    _listenerIndex = globals.currSwatches.addListener(
      (swatch) => setState(() { }),
      (swatch) => setState(() { }),
      () => setState(() { }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LookScreen(
      swatches: globals.currSwatches.currSwatches,
      updateSwatches: (List<int> swatches) {
        setState(() {
          globals.currSwatches.set(swatches);
        });
      },
      name: 'Today\'s Look',
      showBack: true,
      askBackSaved: hasSaved,
      onBackPressed: exit,
      showClear: true,
      onClearPressed: () {
        globals.currSwatches.set([]);
        exit();
      },
      showAdd: false,
      showSave: true,
      onSavePressed: () {
        globalWidgets.openTextDialog(
          context,
          'Enter a name for this look:',
          'You must add a look name.',
          'Save',
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
    globals.currSwatches.removeListener(_listenerIndex);
    navigation.pop(context, false);
  }
}
