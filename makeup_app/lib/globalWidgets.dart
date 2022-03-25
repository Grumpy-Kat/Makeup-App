import 'package:flutter/material.dart' hide FlatButton;
import 'Widgets/FlatButton.dart';
import 'Widgets/StringFormField.dart';
import 'IO/localizationIO.dart';
import 'theme.dart' as theme;
import 'types.dart';

Future<void> openDialog(BuildContext context, Widget Function(BuildContext) builder, { bool barrierDismissible = true }) {
  return showDialog(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
  );
}

Widget getAlertDialog(BuildContext context, { Widget? title, Widget? content, List<Widget>? actions }) {
  return AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    ),
    title: title,
    content: content,
    actions: actions,
  );
}

Future<void> openLoadingDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: theme.bgColor.withAlpha(35),
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

Future<void> openTextDialog(BuildContext context, String title, String error, String buttonLabel, OnStringAction onPressed, { String orgValue = '', bool required = true }) {
  String value = orgValue;
  bool showErrorText = false;
  return openDialog(
    context,
    (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return getAlertDialog(
            context,
            title: Text(title, style: theme.primaryTextBold),
            content: StringFormField(
              value: value,
              error: error,
              showErrorText: showErrorText,
              onChanged: (String val) {
                value = val;
                if(required) {
                  if(showErrorText && val != '') {
                    setState(() { showErrorText = false; });
                  }
                }
              },
              onSubmitted: (String val) {
                value = val;
                if(required) {
                  if(showErrorText && val != '') {
                    setState(() { showErrorText = false; });
                  }
                  if(val == '') {
                    setState(() { showErrorText = true; });
                  }
                }
              }
            ),
            actions: <Widget>[
              FlatButton(
                bgColor: theme.accentColor,
                onPressed: () {
                  if(required && value == '') {
                    setState(() { showErrorText = true; });
                  } else {
                    //doesn't use navigation because is popping a Dialog
                    Navigator.pop(context);
                    onPressed(value);
                  }
                },
                child: Text(
                  buttonLabel,
                  style: theme.accentTextBold,
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
        title: Text(title, style: theme.primaryTextPrimary),
        actions: <Widget>[
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              //doesn't use navigation because is popping an Dialog
              Navigator.pop(context);
              onPressedYes();
            },
            child: Text(
              getString('yes'),
              style: theme.accentTextBold,
            ),
          ),
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              Navigator.pop(context);
              onPressedNo();
            },
            child: Text(
              getString('no'),
              style: theme.accentTextBold,
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

String displayTimeSimple(DateTime date) {
  return '${date.month}-${date.day}-${date.year}';
}

String displayTimeLong(DateTime date) {
  String month;
  switch(date.month) {
    case DateTime.january: {
      month = 'January';
      break;
    }
    case DateTime.february: {
      month = 'February';
      break;
    }
    case DateTime.march: {
      month = 'March';
      break;
    }
    case DateTime.april: {
      month = 'April';
      break;
    }
    case DateTime.may: {
      month = 'May';
      break;
    }
    case DateTime.june: {
      month = 'June';
      break;
    }
    case DateTime.july: {
      month = 'July';
      break;
    }
    case DateTime.august: {
      month = 'August';
      break;
    }
    case DateTime.september: {
      month = 'September';
      break;
    }
    case DateTime.october: {
      month = 'October';
      break;
    }
    case DateTime.november: {
      month = 'November';
      break;
    }
    case DateTime.december: {
      month = 'December';
      break;
    }
    default: {
      month = 'None';
      break;
    }
  }
  return '$month ${date.day}, ${date.year}';
}


DateTime removeTime(DateTime date) {
  return date.subtract(Duration(hours: date.hour, minutes: date.minute, seconds: date.second, milliseconds: date.millisecond, microseconds: date.microsecond));
}

String toTitleCase(String text) {
  List<String> words = text.split(' ');
  String result = '';
  for(int i = 0; i < words.length; i++) {
    if(words[i].length <= 1) {
      result += words[i].toUpperCase() + ' ';
      continue;
    }
    result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1) + ' ';
  }
  return result;
}

String toCamelCase(String text) {
  List<String> words = text.split(' ');
  String result = words[0].toLowerCase();
  for(int i = 1; i < words.length; i++) {
    if(words[i].length <= 1) {
      result += words[i].toUpperCase();
      continue;
    }
    result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
  }
  return result;
}