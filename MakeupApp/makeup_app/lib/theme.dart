import 'package:flutter/material.dart';

bool isDarkTheme = true;

Color get bgColor => isDarkTheme ? Colors.grey[850] : Colors.blueGrey[50];
Color get primaryColorLight => isDarkTheme ? Color.fromRGBO(45, 45, 45 , 1) : Colors.grey[100];
Color get primaryColor => isDarkTheme ? Color.fromRGBO(53, 53, 53 , 1) : Colors.grey[200];
Color get primaryColorDark => isDarkTheme ? Colors.grey[700] : Colors.grey[400];
Color get primaryTextColor => isDarkTheme ? Colors.blueGrey[200] : Colors.grey[800];
Color get accentColorLight => isDarkTheme ? Colors.teal[600] : Colors.teal[300];
Color get accentColor => isDarkTheme ? Colors.teal[400] : Colors.teal[400];
Color get accentColorDark => isDarkTheme ? Colors.teal[300] : Colors.teal[600];
Color get accentTextColor => isDarkTheme ? Colors.grey[850] : Colors.blueGrey[50];
Color get errorTextColor => isDarkTheme ? Colors.red[800] : Colors.red[800];

String get fontFamily => 'Arial';
TextStyle get primaryTitle => TextStyle(color: primaryTextColor, fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: fontFamily);
TextStyle get primaryText => TextStyle(color: primaryTextColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextBold => TextStyle(color: primaryTextColor, fontSize: 20.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSmall => TextStyle(color: primaryTextColor, fontSize: 18.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get primaryTextSmallest => TextStyle(color: primaryTextColor, fontSize: 15.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTitle => TextStyle(color: accentTextColor, fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: fontFamily);
TextStyle get accentText => TextStyle(color: accentTextColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextBold => TextStyle(color: accentTextColor, fontSize: 20.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSmall => TextStyle(color: accentTextColor, fontSize: 18.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get accentTextSmallest => TextStyle(color: accentTextColor, fontSize: 15.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get selectedText => TextStyle(color: accentColor, fontSize: 20.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
TextStyle get errorText => TextStyle(color: errorTextColor, fontSize: 15.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: fontFamily);
