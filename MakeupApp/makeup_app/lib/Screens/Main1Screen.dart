import 'package:flutter/material.dart';
import '../Widgets/Swatch.dart';

class Main1Screen extends StatefulWidget {
  final List<Swatch> Function() loadFormatted;

  Main1Screen(this.loadFormatted);

  @override
  Main1ScreenState createState() => Main1ScreenState();
}

class Main1ScreenState extends State<Main1Screen> {
  List<Swatch> swatches = [];
  List<SwatchIcon> swatchIcons = [];

  void _addSwatches() {
    swatchIcons.clear();
    swatches = widget.loadFormatted();
    for(Swatch swatch in swatches) {
      swatchIcons.add(SwatchIcon(swatch));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
