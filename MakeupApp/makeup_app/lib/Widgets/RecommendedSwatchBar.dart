import 'package:flutter/material.dart';
import '../globals.dart' as global;
import 'Swatch.dart';
import '../ColorMath/ColorProcessing.dart';

class RecommendedSwatchBar extends StatefulWidget {
  @override
  RecommendedSwatchBarState createState() => RecommendedSwatchBarState();
}

class RecommendedSwatchBarState extends State<RecommendedSwatchBar> {
  List<SwatchIcon> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    global.currSwatches.addListener(_addSwatches, null);
  }

  void _addSwatches(Swatch swatch) {
    swatchIcons.clear();
    List<Swatch> recommendedSwatches = getSimilarColors(
        swatch.color,
        swatch,
        global.currSwatches.currSwatches,
        maxDist: 10,
        getSimilar: true,
        getOpposite: true
    );
    recommendedSwatches.sort((a, b) => a.compareTo(b, (swatch) =>  finishSort(swatch, step: 8, firstFinish: swatch.finish)));
    for(Swatch recommendedSwatch in recommendedSwatches) {
      swatchIcons.add(SwatchIcon(recommendedSwatch));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              primary: false,
              padding: const EdgeInsets.all(20),
              itemCount: swatchIcons.length,
              itemBuilder: (BuildContext context, int i) {
                return swatchIcons[i];
              },
            ),
          ),
          SizedBox(
            height: 2.0,
            child: Container(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        ],
      ),
    );
  }
}