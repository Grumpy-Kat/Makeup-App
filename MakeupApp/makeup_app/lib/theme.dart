import 'package:flutter/material.dart';

bool isDarkTheme = true;

Color get bgColor => isDarkTheme ? Color.fromRGBO(18, 18, 18, 1) : Color.fromRGBO(248, 249, 251, 1);
Color get primaryColorLight => isDarkTheme ? Color.fromRGBO(15, 15, 15, 1) : Color.fromRGBO(251, 252, 254, 1);
Color get primaryColor => isDarkTheme ? Color.fromRGBO(20, 20, 20 , 1) : Color.fromRGBO(244, 245, 247, 1);
Color get primaryColorDark => isDarkTheme ? Color.fromRGBO(40, 40, 40, 1) : Color.fromRGBO(219, 220, 222, 1);
Color get primaryColorDarkest => isDarkTheme ? Color.fromRGBO(117, 117, 117, 1) : Color.fromRGBO(153, 154, 156, 1);
Color get primaryTextColor => isDarkTheme ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(0, 0, 0, 1);
Color get secondaryTextColor => isDarkTheme ? Color.fromRGBO(195, 195, 201, 1) : Color.fromRGBO(54, 54, 56, 1);
Color get tertiaryTextColor => isDarkTheme ? Color.fromRGBO(141, 141, 147, 1) : Color.fromRGBO(109, 109, 114, 1);
Color get iconTextColor => isDarkTheme ? Color.fromRGBO(185, 185, 191, 1) : Color.fromRGBO(64, 64, 66, 1);
Color get accentColorLight => isDarkTheme ? Colors.teal[600] : Colors.teal[300];
Color get accentColor => isDarkTheme ? Color.fromRGBO(39, 165, 146, 1) : Color.fromRGBO(39, 165, 146, 1);
Color get accentColorDark => isDarkTheme ? Colors.teal[300] : Colors.teal[600];
Color get accentTextColor => isDarkTheme ? Color.fromRGBO(244, 245, 248, 1) : Color.fromRGBO(248, 249, 251, 1);
Color get unselectedTextColor => isDarkTheme ? Color.fromRGBO(244, 245, 248, 1) : Color.fromRGBO(248, 249, 251, 1);
Color get checkTextColor => isDarkTheme ? Color.fromRGBO(67, 163, 79, 1) : Color.fromRGBO(27, 132, 39, 1);
Color get errorTextColor => isDarkTheme ? Color.fromRGBO(209, 82, 88, 1) : Color.fromRGBO(230, 0, 32, 1);

double get titleTextSize => 34.0;
double get primaryTextSize => 17;
double get primaryIconSize => 24.0;
double get secondaryTextSize => 15.0;
double get secondaryIconSize => 22.0;
double get tertiaryTextSize => 13.0;
double get tertiaryIconSize => 21.0;
double get quaternaryTextSize => 12.0;
double get quaternaryIconSize => 23.0;

String get fontFamily => 'Montserrat';
TextStyle get primaryTitle => TextStyle(color: primaryTextColor, fontSize: titleTextSize, fontWeight: FontWeight.bold, fontFamily: fontFamily);
TextStyle get primaryTextBold => TextStyle(color: primaryTextColor, fontSize: primaryTextSize, fontWeight: FontWeight.w500, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextPrimary => TextStyle(color: primaryTextColor, fontSize: primaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSecondary => TextStyle(color: secondaryTextColor, fontSize: secondaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextTertiary => TextStyle(color: tertiaryTextColor, fontSize: secondaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextQuaternary => TextStyle(color: secondaryTextColor, fontSize: quaternaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextBold => TextStyle(color: accentTextColor, fontSize: primaryTextSize, fontWeight: FontWeight.w500, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextPrimary => TextStyle(color: accentTextColor, fontSize: primaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSecondary => TextStyle(color: accentTextColor, fontSize: secondaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextTertiary => TextStyle(color: accentTextColor, fontSize: secondaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get selectedText => TextStyle(color: accentColor, fontSize: primaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get errorText => TextStyle(color: errorTextColor, fontSize: primaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get errorTextLabel => TextStyle(color: errorTextColor, fontSize: secondaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
