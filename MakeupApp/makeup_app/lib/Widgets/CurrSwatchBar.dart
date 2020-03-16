import 'package:flutter/material.dart';
import '../globals.dart' as global;
import 'Swatch.dart';

class CurrSwatchBar extends StatefulWidget {
  @override CurrSwatchBarState createState() => CurrSwatchBarState();
}

class CurrSwatchBarState extends State<CurrSwatchBar> {
  List<SwatchIcon> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    global.currSwatches.addListener(_addSwatches, _addSwatches);
  }

  void _addSwatches(Swatch swatch) {
    swatchIcons.clear();
    for(Swatch swatch in global.currSwatches.currSwatches) {
      swatchIcons.add(SwatchIcon(swatch));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        primary: false,
        padding: const EdgeInsets.all(20),
        itemCount: swatchIcons.length,
        itemBuilder: (BuildContext context, int i) {
          return swatchIcons[i];
        },
      ),
    );
  }
}