import 'package:flutter/material.dart';
import 'theme.dart' as theme;
import 'types.dart';

Future<void> openDialog(BuildContext context, Widget Function(BuildContext) builder) {
  return showDialog(
    context: context,
    builder: builder,
  );
}

Widget getAlertDialog(BuildContext context, { Widget title, Widget content, List<Widget> actions }) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    title: title,
    content: content,
    actions: actions,
  );
}

Future<void> openTextDialog(BuildContext context, String title, String error, String buttonLabel, OnStringAction onPressed) {
  String value = '';
  bool showErrorText = false;
  return openDialog(
    context,
    (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return getAlertDialog(
            context,
            title: Text(title, style: theme.primaryTextBold),
            content: TextField(
              autofocus: true,
              textAlign: TextAlign.left,
              style: theme.primaryTextSmall,
              cursorColor: theme.accentColor,
              decoration: InputDecoration(
                labelStyle: theme.primaryTextSmall,
                errorText: showErrorText ? error : null,
                errorStyle: theme.errorText,
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
                value = val;
                if(showErrorText && !(val == '' || val == null)) {
                  setState(() { showErrorText = false; });
                }
              },
            ),
            actions: <Widget>[
              FlatButton(
                color: theme.accentColor,
                onPressed: () {
                  if(value == '' || value == null) {
                    setState(() { showErrorText = true; });
                  } else {
                    //doesn't use navigation because is popping a Dialog
                    Navigator.pop(context);
                    onPressed(value);
                  }
                },
                child: Text(
                  buttonLabel,
                  style: theme.accentText,
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Future<void> openTwoTextDialog(BuildContext context, String title, String label1, String label2, String error1, String error2, String buttonLabel, void Function(String, String) onPressed) {
  String value1 = '';
  String value2 = '';
  bool showErrorText1 = false;
  bool showErrorText2 = false;
  return openDialog(
    context,
    (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return getAlertDialog(
            context,
            title: Text(title, style: theme.primaryTextBold),
            content: Column(
              children: <Widget> [
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.left,
                  style: theme.primaryTextSmall,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    labelText: label1,
                    labelStyle: theme.primaryTextSmall,
                    errorText: showErrorText1 ? error2 : null,
                    errorStyle: theme.errorText,
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
                    value1 = val;
                    if(showErrorText1 && !(val == '' || val == null)) {
                      setState(() { showErrorText1 = false; });
                    }
                  },
                ),
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.left,
                  style: theme.primaryTextSmall,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    labelText: label2,
                    labelStyle: theme.primaryTextSmall,
                    errorText: showErrorText2 ? error1 : null,
                    errorStyle: theme.errorText,
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
                    value2 = val;
                    if(showErrorText2 && !(val == '' || val == null)) {
                      setState(() { showErrorText2 = false; });
                    }
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                color: theme.accentColor,
                onPressed: () {
                  if(value1 == '' || value1 == null || value2 == '' || value2 == null) {
                    if(value1 == '' || value1 == null) {
                      setState(() { showErrorText1 = true; });
                    } else {
                      setState(() { showErrorText2 = true; });
                    }
                  } else {
                    //doesn't use navigation because is popping a Dialog
                    Navigator.pop(context);
                    onPressed(value1, value2);
                  }
                },
                child: Text(
                  buttonLabel,
                  style: theme.accentText,
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Future<void> openTwoButtonDialog(BuildContext context, String title, OnVoidAction onPressedYes, OnVoidAction onPressedNo) {
  return openDialog(
    context,
    (BuildContext context) {
      return getAlertDialog(
        context,
        title: Text(title, style: theme.primaryText),
        actions: <Widget>[
          FlatButton(
            color: theme.accentColor,
            onPressed: () {
              //doesn't use navigation because is popping an Dialog
              Navigator.pop(context);
              onPressedYes();
            },
            child: Text(
              'Yes',
              style: theme.accentText,
            ),
          ),
          FlatButton(
            color: theme.accentColor,
            onPressed: () {
              Navigator.pop(context);
              onPressedNo();
            },
            child: Text(
              'No',
              style: theme.accentText,
            ),
          ),
        ],
      );
    },
  );
}

PageRouteBuilder slideTransition(BuildContext context, Widget nextScreen, int duration, Offset begin, Offset end) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: duration),
    pageBuilder: (context, animation, secondaryAnimation) { return nextScreen; },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(
          begin: begin,
          end: end,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCirc,
          ),
        ),
        child: child,
      );
    },
  );
}

String toTitleCase(String text) {
  List<String> words = text.split(' ');
  String result = '';
  for(int i = 0; i < words.length; i++) {
    if(words[i].length <= 1) {
      result += words[i].toUpperCase();
      continue;
    }
    result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1) + ' ';
  }
  return result;
}