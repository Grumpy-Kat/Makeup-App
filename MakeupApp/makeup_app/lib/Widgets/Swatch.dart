import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorProcessing.dart';

class Swatch {
  RGBColor color;
  String finish;
  String palette;

  Swatch(this.color, this.finish, this.palette);

  int compareTo(Swatch other, List<double> Function(Swatch) comparator) {
    List<double> thisValues = comparator(this);
    List<double> otherValues = comparator(other);
    for(int i = 0; i < thisValues.length; i++) {
      int comp = thisValues[i].compareTo(otherValues[i]);
      if(comp != 0) {
        return comp;
      }
    }
    return 0;
  }
}

class SwatchIcon extends StatelessWidget {
  final Swatch swatch;

  SwatchIcon(this.swatch);

  @override
  Widget build(BuildContext context) {
    List<double> color = swatch.color.getValues();
    String colorName = getColorName(swatch.color);
    String finish = swatch.finish;
    String palette = swatch.palette;
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Tooltip(
        preferBelow: true,
        message: 'Color: $colorName\nFinish: $finish\nPalette: $palette',
        child: CircleAvatar(
          foregroundColor: Color.fromRGBO((color[0] * 255).round(), (color[1] * 255).round(), (color[2] * 255).round(), 1),
          backgroundImage: AssetImage('imgs/$finish.jpg'),
          radius: 50,
        ),
      )
    );
  }

  void _onDoubleTap() {
    if(!globals.currSwatches.currSwatches.contains(this)) {
      globals.currSwatches.add(swatch);
    }
  }
}