import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../globals.dart' as globals;
import '../navigation.dart' as navigation;
import '../theme.dart' as theme;
import '../routes.dart' as routes;
import 'Swatch.dart';

class CurrSwatchBar extends StatefulWidget {
  @override CurrSwatchBarState createState() => CurrSwatchBarState();
}

class CurrSwatchBarState extends State<CurrSwatchBar> {
  List<SwatchIcon> swatchIcons = [];
  bool origInit = true;

  @override
  void initState() {
    super.initState();
    globals.currSwatches.addListener(
      (swatch) => setState(() { _addSwatches(); }),
      (swatch) => setState(() { _addSwatches(); }),
      () => setState(() { _addSwatches(); }),
    );
    if(origInit) {
      origInit = false;
      _addSwatches();
    }
  }

  @override
  void setState(func) {
    if(mounted) {
      super.setState(func);
    }
  }

  void _addSwatches() {
    swatchIcons.clear();
    for(int i = 0; i < globals.currSwatches.length; i++) {
      swatchIcons.add(
        SwatchIcon.id(
          globals.currSwatches.currSwatches[i],
          showInfoBox: false,
          overrideOnDoubleTap: true,
          onDoubleTap: (int i) {
            _onDoubleTap();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Container(
        color: theme.primaryColor,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          primary: false,
          padding: const EdgeInsets.all(20),
          separatorBuilder: (BuildContext context, int i) {
            return const SizedBox(
              width: 15,
            );
          },
          itemCount: swatchIcons.length,
          itemBuilder: (BuildContext context, int i) {
            return swatchIcons[i];
          },
        ),
      ),
    );
  }

  void _onDoubleTap() {
    navigation.push(
      context,
      const Offset(1, 0),
      routes.ScreenRoutes.TodayLookScreen,
      routes.routes['/todayLookScreen']!(context),
    );
  }
}