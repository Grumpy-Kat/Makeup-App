import 'package:flutter/material.dart';
import 'ColorMath/ColorObjects.dart';
import 'Widgets/Swatch.dart';

typedef OnVoidAction = void Function();
typedef OnStringAction = void Function(String);
typedef OnStringListAction = void Function(List<String>);
typedef OnRGBColorAction = void Function(RGBColor);
typedef OnIntAction = void Function(int);
typedef OnDoubleAction = void Function(double);
//same thing, but for clarity
typedef OnSwatchAction = void Function(int);
typedef OnSwatchListAction = void Function(List<int>);
typedef OnDoubleSwatchListAction = void Function(List<List<int>>);
typedef OnSortSwatch = List<double> Function(Swatch, int);
typedef OnScreenAction = StatefulWidget Function(BuildContext);