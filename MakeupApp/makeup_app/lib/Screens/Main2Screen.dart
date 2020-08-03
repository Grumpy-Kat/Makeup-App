import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/MultipleSwatchList.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;

class Main2Screen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  Main2Screen(this.loadFormatted);

  @override
  Main2ScreenState createState() => Main2ScreenState();
}

class Main2ScreenState extends State<Main2Screen> with ScreenState {
  List<Swatch> swatches = [];
  List<SwatchIcon> swatchIcons = [];

  void _addSwatches() async {
    swatches = await widget.loadFormatted();
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      widget.loadFormatted,
      2,
      Column(
        children: <Widget>[

        ],
      ),
    );
  }
}
