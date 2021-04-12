import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'IO/localizationIO.dart';
import 'theme.dart' as theme;
import 'types.dart';
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;

Future<void> openDialog(BuildContext context, Widget Function(BuildContext) builder) {
  return showDialog(
    context: context,
    builder: builder,
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
            content: getTextField(
              context,
              null,
              value,
              error,
              showErrorText,
              (String val) {
                value = val;
                if(required) {
                  if(showErrorText && val != '') {
                    setState(() { showErrorText = false; });
                  }
                }
              },
              (String val) {
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
              getFlatButton(
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

Future<void> openPaletteTextDialog(BuildContext context, String title, void Function(String, String, double, double) onPressed) {
  String brand = '';
  String palette = '';
  double weight = 0.0;
  double price = 0.00;
  List<bool> showErrorTexts = [false, false];
  return openDialog(
    context,
    (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return getAlertDialog(
            context,
            title: Text(title, style: theme.primaryTextBold),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget> [
                  getTextField(
                    context,
                    getString('addPalette_brand'),
                    brand,
                    getString('addPalette_brandError'),
                    showErrorTexts[0],
                    (String val) {
                      brand = val;
                      if(showErrorTexts[0] && val != '') {
                        setState(() { showErrorTexts[0] = false; });
                      }
                    },
                    (String val) {
                      brand = val;
                      if(brand != '') {
                        setState(() { showErrorTexts[0] = false; });
                      }
                      if(brand == '') {
                        setState(() { showErrorTexts[0] = true; });
                      }
                    }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getTextField(
                    context,
                    getString('addPalette_palette'),
                    palette,
                    getString('addPalette_paletteError'),
                    showErrorTexts[1],
                    (String val) {
                      palette = val;
                      if(showErrorTexts[1] && val != '') {
                        setState(() { showErrorTexts[1] = false; });
                      }
                    },
                    (String val) {
                      palette = val;
                      if(palette != '') {
                        setState(() { showErrorTexts[1] = false; });
                      }
                      if(palette == '') {
                        setState(() { showErrorTexts[1] = true; });
                      }
                    }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getNumField(
                    context,
                    getString('addPalette_weight'),
                    weight,
                    '',
                    false,
                    (double val) {
                      weight = double.parse(val.toStringAsFixed(4));
                    },
                    (double val) {
                      setState(() {
                        weight = double.parse(val.toStringAsFixed(4));
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getNumField(
                    context,
                    getString('addPalette_price'),
                    price,
                    '',
                    false,
                    (double val) {
                      price = double.parse(val.toStringAsFixed(2));
                    },
                    (double val) {
                      setState(() {
                        price = double.parse(val.toStringAsFixed(2));
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              getFlatButton(
                bgColor: theme.accentColor,
                onPressed: () {
                  if(brand == '' || palette == '') {
                    if(brand == '') {
                      setState(() { showErrorTexts[0] = true; });
                    }
                    if(palette == '') {
                      setState(() { showErrorTexts[1] = true; });
                    }
                  } else {
                    //doesn't use navigation because is popping a Dialog
                    Navigator.pop(context);
                    onPressed(brand, palette, weight, price);
                  }
                },
                child: Text(
                  getString('save'),
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
          getFlatButton(
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
          getFlatButton(
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

Widget getHelpBtn(BuildContext context, String text) {
  return IconButton(
    constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
    icon: Icon(
      Icons.help,
      size: 25.0,
      color: theme.iconTextColor,
    ),
    onPressed: () {
      //opens help dialog
      openDialog(
        context,
        (BuildContext context) {
          return getAlertDialog(
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
                child: getFlatButton(
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

Widget getTextField(BuildContext context, String? label, String? value, String? error, bool showErrorText, OnStringAction? onChanged, OnStringAction? onSubmitted) {
  return TextFormField(
    autofocus: true,
    textAlign: TextAlign.left,
    style: theme.primaryTextSecondary,
    textCapitalization: TextCapitalization.words,
    cursorColor: theme.accentColor,
    textInputAction: TextInputAction.done,
    initialValue: value,
    decoration: InputDecoration(
      fillColor: theme.primaryColor,
      labelText: label,
      labelStyle: theme.primaryTextSecondary,
      errorText: showErrorText ? error : null,
      errorStyle: theme.errorTextSecondary,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 2.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.primaryColorDark,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.accentColor,
          width: 2.5,
        ),
      ),
    ),
    onChanged: onChanged,
    onFieldSubmitted: onSubmitted,
  );
}

Widget getNumField(BuildContext context, String? label, double? value, String? error, bool showErrorText, OnDoubleAction? onChanged, OnDoubleAction? onSubmitted) {
  return TextFormField(
    autofocus: true,
    textAlign: TextAlign.left,
    style: theme.primaryTextSecondary,
    textInputAction: TextInputAction.done,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    cursorColor: theme.accentColor,
    initialValue: value.toString(),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
    ],
    decoration: InputDecoration(
      fillColor: theme.primaryColor,
      labelText: label,
      labelStyle: theme.primaryTextSecondary,
      errorText: showErrorText ? error : null,
      errorStyle: theme.errorTextSecondary,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 2.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.primaryColorDark,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.accentColor,
          width: 2.5,
        ),
      ),
    ),
    onChanged: (String val) {
      if(onChanged != null) {
        onChanged(double.parse(val));
      }
    },
    onFieldSubmitted: (String val) {
      if(onSubmitted != null) {
        onSubmitted(double.parse(val));
      }
    },
  );
}

Widget getBackButton(OnVoidAction onPressed) {
  return IconButton(
    constraints: BoxConstraints.tight(const Size.fromWidth(26)),
    icon: Icon(
      Icons.arrow_back_ios,
      size: 19,
      color: theme.iconTextColor,
    ),
    onPressed: onPressed,
  );
}

Widget getLoginButton(BuildContext context) {
  return IconButton(
    constraints: BoxConstraints.tight(const Size.fromWidth(40)),
    icon: Icon(
      Icons.account_circle,
      size: 25,
      color: theme.iconTextColor,
    ),
    onPressed: () {
      navigation.push(
        context,
        const Offset(-1, 0),
        routes.ScreenRoutes.LoginScreen,
        routes.routes['/loginScreen']!(context),
      );
    },
  );
}

Widget getFlatButton({ OnVoidAction? onPressed, required Widget child, EdgeInsets? padding, Color? bgColor, Color? splashColor }) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: bgColor ?? Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(2)),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return splashColor ?? theme.accentColor.withAlpha(130);
          }
          return null;
        },
      ),
    ),
    child: child,
  );
}

Widget getOutlineButton({ OnVoidAction? onPressed, required Widget child, EdgeInsets? padding, Color? bgColor, Color? outlineColor, double? outlineWidth, Color? splashColor }) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: bgColor ?? Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(2)),
      ),
    ).copyWith(
      side: MaterialStateProperty.resolveWith<BorderSide?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return BorderSide(
              color: outlineColor ?? theme.primaryColorDark,
              width: outlineWidth ?? 1,
            );
          }
          return null;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return splashColor ?? theme.accentColor.withAlpha(130);
          }
          return null;
        },
      ),
    ),
    child: child,
  );
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