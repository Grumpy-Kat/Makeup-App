import 'package:flutter/material.dart';
import 'theme.dart' as theme;
import 'types.dart';

Future<void> openDialog(BuildContext context, { Widget title, Widget content, List<Widget> actions }) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        title: title,
        content: content,
        actions: actions,
      );
    }
  );
}

Future<void> openTextDialog(BuildContext context, String title, String error, String buttonLabel, OnStringAction onPressed) {
  String value;
  return openDialog(
    context,
    title: Text(title),
    content: TextField(
      autofocus: true,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        errorText: (value == '') ? error : null,
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
      },
    ),
    actions: <Widget>[
      FlatButton(
        color: theme.accentColor,
        onPressed: () {
          //doesn't use navigation because is popping a Dialog
          Navigator.pop(context);
          onPressed(value);
        },
        child: Text(
          buttonLabel,
          style: theme.accentText,
        ),
      )
    ],
  );
}

Future<void> openTwoTextDialog(BuildContext context, String title, String label1, String label2, String error1, String error2, String buttonLabel, void Function(String, String) onPressed) {
  String value1;
  String value2;
  return openDialog(
    context,
    title: Text(title),
    content: Column(
      children: <Widget> [
        TextField(
          autofocus: true,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            labelText: label1,
            errorText: (value1 == '') ? error1 : null,
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
          },
        ),
        TextField(
          autofocus: true,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            labelText: label2,
            errorText: (value2 == '') ? error2 : null,
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
          },
        ),
      ],
    ),
    actions: <Widget>[
      FlatButton(
        color: theme.accentColor,
        onPressed: () {
          //doesn't use navigation because is popping an Dialog
          Navigator.pop(context);
          onPressed(value1, value2);
        },
        child: Text(
          buttonLabel,
          style: theme.accentText,
        ),
      )
    ],
  );
}

Future<void> openTwoButtonDialog(BuildContext context, String title, OnVoidAction onPressedYes, OnVoidAction onPressedNo) {
  return openDialog(
    context,
    title: Text(title),
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