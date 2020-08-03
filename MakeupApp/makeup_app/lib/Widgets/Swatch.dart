import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorProcessing.dart';
import 'InfoBox.dart';

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
  final GlobalKey infoBoxKey = GlobalKey();
  final int index;
  final bool showInfoBox;

  SwatchIcon(this.swatch, this.index, { this.showInfoBox = true });

  @override
  Widget build(BuildContext context) {
    List<double> color = swatch.color.getValues();
    String colorName = _toTitleCase(getColorName(swatch.color));
    String finish = _toTitleCase(swatch.finish);
    String palette = _toTitleCase(swatch.palette);
    final Widget child = Image(
      image: AssetImage('imgs/${finish.toLowerCase()}.png'),
      colorBlendMode: BlendMode.modulate,
      color: Color.fromRGBO((color[0] * 255).round(), (color[1] * 255).round(), (color[2] * 255).round(), 1),
    );
    if(showInfoBox) {
      return InfoBox(
        key: infoBoxKey,
        color: colorName,
        finish: finish,
        palette: palette,
        verticalOffset: 95.0,
        onTap: _onTap,
        onDoubleTap: _onDoubleTap,
        index: index,
        child: child,
      );
    }
    return GestureDetector(
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      child: child,
    );
  }

  void _onTap() {
    (infoBoxKey?.currentState as InfoBoxState).open();
  }

  void _onDoubleTap() {
    if(!globals.currSwatches.currSwatches.contains(this)) {
      globals.currSwatches.add(swatch);
    }
  }

  String _toTitleCase(String text) {
    List<String> words = text.split(' ');
    String result = '';
    for(int i = 0; i < words.length; i++) {
      if(words[i].length <= 1) {
        result += words[i].toUpperCase();
        continue;
      }
      result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
    }
    return result;
  }
}