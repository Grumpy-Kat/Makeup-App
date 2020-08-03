import 'package:flutter/material.dart';
import '../Screens/LookScreen.dart';
import '../Widgets/Swatch.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

class TodayLookScreen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;
  final void Function(int, String, List<Swatch>) save;

  TodayLookScreen(this.loadFormatted, this.save);

  @override
  TodayLookScreenState createState() => TodayLookScreenState();
}

class TodayLookScreenState extends State<TodayLookScreen>  {
  String lookName = "";

  @override
  void initState() {
    super.initState();
    globals.currSwatches.addListener(
      (swatch) => setState(() { }),
      (swatch) => setState(() { }),
      () => setState(() { }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LookScreen(
      loadFormatted: widget.loadFormatted,
      swatches: globals.currSwatches.currSwatches,
      updateSwatches: (List<Swatch> swatches) {
        setState(() {
          globals.currSwatches.set(swatches);
        });
      },
      name: 'Today\'s Look',
      showBack: true,
      onBackPressed: () {
        Navigator.pop(context);
      },
      showClear: true,
      onClearPressed: () {
        setState(() {
          globals.currSwatches.set([]);
        });
      },
      showAdd: false,
      showSave: true,
      onSavePressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter a name for this look:'),
              content: TextField(
                autofocus: true,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  errorText: (lookName == "") ? 'You must add a look name.' : null,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.primaryColorDark,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.accentColor,
                      width: 2.5,
                    ),
                  ),
                ),
                onChanged: (String val) {
                  lookName = val;
                },
              ),
              actions: <Widget>[
                FlatButton(
                  color: theme.accentColor,
                  onPressed: () {
                    //TODO: change to SavedLookScreen
                    widget.save(-1, lookName, globals.currSwatches.currSwatches);
                  },
                  child: Text(
                    'Save',
                    style: theme.accentText,
                  ),
                )
              ],
            );
          }
        );
      },
      showEdit: true,
    );
  }
}
