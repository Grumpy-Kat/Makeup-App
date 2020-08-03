import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;

class Main3Screen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  Main3Screen(this.loadFormatted);

  @override
  Main3ScreenState createState() => Main3ScreenState();
}

class Main3ScreenState extends State<Main3Screen> with ScreenState {
  List<Swatch> swatches = [];
  List<SwatchIcon> swatchIcons = [];

  void _addSwatches() async {
    swatchIcons.clear();
    swatches = await widget.loadFormatted();
    for(int i = 0; i < swatches.length; i++) {
      swatchIcons.add(SwatchIcon(swatches[i], i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      widget.loadFormatted,
      3,
      Column(
        children: <Widget>[

        ],
      ),
    );
  }
}
