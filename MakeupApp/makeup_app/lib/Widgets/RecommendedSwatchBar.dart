import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../ColorMath/ColorProcessing.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import 'Swatch.dart';

class RecommendedSwatchBar extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  RecommendedSwatchBar(this.loadFormatted);

  @override
  RecommendedSwatchBarState createState() => RecommendedSwatchBarState();
}

class RecommendedSwatchBarState extends State<RecommendedSwatchBar> {
  List<OverlayEntry> _overlayEntries = [];
  bool isOpening = false;

  List<SwatchIcon> swatchIcons = [];

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(onPointerEvent);
    globals.currSwatches.addListener(
      (swatch) => setState(() { _addSwatches(swatch); }),
      null,
      null,
    );
  }

  @override
  void setState(func) {
    if(mounted) {
      super.setState(func);
    }
  }

  void _addSwatches(Swatch swatch) {
    widget.loadFormatted().then((List<Swatch> allSwatches) {
      swatchIcons.clear();
      List<Swatch> recommendedSwatches = getSimilarColors(
          swatch.color,
          swatch,
          allSwatches,
          maxDist: 10,
          getSimilar: true,
          getOpposite: true,
      );
      recommendedSwatches.sort((a, b) => a.compareTo(b, (swatch) =>  finishSort(swatch, step: 8, firstFinish: swatch.finish)));
      for(int i = 0; i < recommendedSwatches.length; i++) {
        swatchIcons.add(SwatchIcon(recommendedSwatches[i], i, showInfoBox: false));
      }
      open(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
    );
  }

  void onPointerEvent(PointerEvent event) {
    if(event is PointerUpEvent || event is PointerCancelEvent || event is PointerDownEvent) {
      if(context != null) {
        double y = MediaQuery.of(context).size.height * 0.8;
        double height = MediaQuery.of(context).size.height * 0.1;
        Offset pointer = event.position;
        print('$y $height $pointer');
        if(pointer.dy < y || pointer.dy > y + height) {
          print('close');
          //not closing previous ones
          close();
        }
      }
    }
  }

  //TODO: add fade in/out animation
  void open(BuildContext context) {
    final Widget overlay = Positioned(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      bottom: (MediaQuery.of(context).size.height * 0.1) - 3,
      left: 0,
      child: Container(
        color: theme.primaryColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                primary: false,
                padding: const EdgeInsets.all(20),
                separatorBuilder: (BuildContext context, int i) {
                  return SizedBox(
                    width: 15,
                  );
                },
                itemCount: swatchIcons.length,
                itemBuilder: (BuildContext context, int i) {
                  return swatchIcons[i];
                },
              ),
            ),
            SizedBox(
              height: 2.0,
              child: Container(
                color: theme.primaryColorLight,
              ),
            ),
          ],
        ),
      ),
    );
    _overlayEntries.add(OverlayEntry(builder: (BuildContext context) => overlay));
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntries.last);
    isOpening = true;
    Future.delayed(const Duration(milliseconds: 500), () { isOpening = false; });
  }

  void close() {
    if(!isOpening) {
      for(int i = 0; i < _overlayEntries.length; i++) {
        _overlayEntries[i]?.remove();
      }
      _overlayEntries = [];
    }
  }
}