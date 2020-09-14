import 'package:flutter/material.dart';

bool isDarkTheme = true;

Color get bgColor => isDarkTheme ? Color.fromRGBO(18, 18, 18, 1) : Color.fromRGBO(248, 249, 251, 1);
Color get primaryColorLight => isDarkTheme ? Color.fromRGBO(15, 15, 15, 1) : Color.fromRGBO(251, 252, 254, 1);
Color get primaryColor => isDarkTheme ? Color.fromRGBO(20, 20, 20 , 1) : Color.fromRGBO(244, 245, 247, 1);
Color get primaryColorDark => isDarkTheme ? Color.fromRGBO(35, 35, 35, 1) : Color.fromRGBO(221, 222, 224, 1);
Color get primaryTextColor => isDarkTheme ? Color.fromRGBO(221, 222, 224, 1) : Color.fromRGBO(35, 35, 35, 1);
Color get accentColorLight => isDarkTheme ? Colors.teal[600] : Colors.teal[300];
Color get accentColor => isDarkTheme ? Colors.teal[400] : Colors.teal[400];
Color get accentColorDark => isDarkTheme ? Colors.teal[300] : Colors.teal[600];
Color get accentTextColor => isDarkTheme ? Color.fromRGBO(244, 245, 248, 1) : Color.fromRGBO(248, 249, 251, 1);
Color get errorTextColor => isDarkTheme ? Color.fromRGBO(207, 73, 80, 1) : Color.fromRGBO(176, 0, 32, 1);

String get fontFamily => 'Arial';
TextStyle get primaryTitle => TextStyle(color: primaryTextColor, fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: fontFamily);
TextStyle get primaryText => TextStyle(color: primaryTextColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextBold => TextStyle(color: primaryTextColor, fontSize: 20.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSmall => TextStyle(color: primaryTextColor, fontSize: 18.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSmaller => TextStyle(color: primaryTextColor, fontSize: 14.5, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSmallest => TextStyle(color: primaryTextColor, fontSize: 13.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTitle => TextStyle(color: accentTextColor, fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: fontFamily);
TextStyle get accentText => TextStyle(color: accentTextColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextBold => TextStyle(color: accentTextColor, fontSize: 20.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSmall => TextStyle(color: accentTextColor, fontSize: 18.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSmaller => TextStyle(color: accentTextColor, fontSize: 14.5, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSmallest => TextStyle(color: accentTextColor, fontSize: 13.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get selectedText => TextStyle(color: accentColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get errorText => TextStyle(color: errorTextColor, fontSize: 15.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
