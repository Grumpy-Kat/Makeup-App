import 'package:flutter/material.dart' hide FlatButton;
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import'FlatButton.dart';

class HelpButton extends StatelessWidget {
  final String text;

  HelpButton({ Key? key, required this.text }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
      icon: Icon(
        Icons.help,
        size: 25.0,
        color: theme.iconTextColor,
      ),
      onPressed: () {
        //opens help dialog
        globalWidgets.openDialog(
          context,
          (BuildContext context) {
            return globalWidgets.getAlertDialog(
              context,
              content: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: Text(text, style: theme.primaryTextSecondary),
                ),
              ),
              actions: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: FlatButton(
                    bgColor: theme.accentColor,
                    onPressed: () {
                      //doesn't use navigation because is popping an Dialog
                      Navigator.pop(context);
                    },
                    child: Text(
                      getString('close'),
                      style: theme.accentTextSecondary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }
}
