import 'package:flutter/material.dart';
import '../Widgets/MenuBar.dart';
import '../Widgets/CurrSwatchBar.dart';
import '../Widgets/RecommendedSwatchBar.dart';
import '../Widgets/Swatch.dart';

class Main0Screen extends StatefulWidget {
  final List<Swatch> Function() loadFormatted;

  Main0Screen(this.loadFormatted);

  @override
  Main0ScreenState createState() => Main0ScreenState();
}

class Main0ScreenState extends State<Main0Screen> {
  List<Swatch> swatches = [];
  List<SwatchIcon> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    _addSwatches();
  }

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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: MenuBar(),
            ),
            Expanded(
              flex: 7,
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                primary: true,
                padding: const EdgeInsets.all(20),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15, crossAxisSpacing: 15, crossAxisCount: 3),
                itemCount: swatchIcons.length + 1,
                itemBuilder: (BuildContext context, int i) {
                  if(swatchIcons.length  == 0) {
                    return Text('No colors found!', textAlign: TextAlign.center);
                  } else if(swatchIcons.length == i) {
                    return RaisedButton.icon(
                      icon: Icon(Icons.add),
                      onPressed: () {},
                    );
                  }
                  return swatchIcons[i];
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: RecommendedSwatchBar(),
            ),
            Expanded(
              flex: 1,
              child: CurrSwatchBar(),
            ),
          ],
        )
      ),
    );
  }
}
