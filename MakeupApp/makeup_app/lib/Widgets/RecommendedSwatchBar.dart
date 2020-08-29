import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import '../ColorMath/ColorProcessing.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../allSwatchesIO.dart' as IO;
import 'Swatch.dart';
import 'SwatchList.dart';

class RecommendedSwatchBar extends StatefulWidget {
  @override
  RecommendedSwatchBarState createState() => RecommendedSwatchBarState();
}

class RecommendedSwatchBarState extends State<RecommendedSwatchBar> with TickerProviderStateMixin, SwatchListState {
  List<OverlayEntry> _overlayEntries = [];
  bool _isOpening = false;

  List<AnimationController> _controllers = [];

  Swatch currSwatch;
  List<int> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];
  Future<List<int>> _swatchesFuture;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(onPointerEvent);
    globals.currSwatches.addListener(
      (swatch) => setState(() {
        currSwatch = IO.get(swatch);
        _swatchesFuture = _addSwatches();
        open(context);
      }),
      null,
      null,
    );
    init(
      SwatchList(
        addSwatches: _swatchesFuture,
        selectedSwatches: [],
        showInfoBox: true,
        showNoColorsFound: true,
        showDelete: false,
        overrideOnTap: false,
        overrideOnDoubleTap: false,
      ),
    );
  }

  @override
  void setState(func) {
    if(mounted) {
      super.setState(func);
    }
  }

  Future<List<int>> _addSwatches() async {
    int maxSwatches = 10;
    List<int> allSwatches = await IO.loadFormatted();
    List<int> currSwatches = globals.currSwatches.currSwatches;
    List<int> recommendedSwatches = [];
    _swatchIcons.clear();
    for(int i = 0; i < currSwatches.length; i++) {
      recommendedSwatches.addAll(
        IO.findMany(
          getSimilarColors(
            currSwatch.color,
            currSwatch,
            IO.getMany(allSwatches),
            maxDist: 10,
            getSimilar: true,
            getOpposite: true,
          ),
        ),
      );
    }
    Map<int, int> occurrences = {};
    for(int i = 0; i < recommendedSwatches.length; i++) {
      //skip swatches that are already in Today's Look
      if(currSwatches.contains(recommendedSwatches[i])) {
        continue;
      }
      if(occurrences.containsKey(recommendedSwatches[i])) {
        occurrences[recommendedSwatches[i]]++;
      } else {
        occurrences[recommendedSwatches[i]] = 1;
      }
    }
    recommendedSwatches = occurrences.keys.toList(growable: false);
    recommendedSwatches.sort((a, b) => occurrences[b].compareTo(occurrences[a]));
    maxSwatches = min(maxSwatches, recommendedSwatches.length);
    for(int i = 0; i < maxSwatches; i++) {
      if(recommendedSwatches[i] != null) {
        _swatchIcons.add(SwatchIcon.id(recommendedSwatches[i], showInfoBox: true));
      }
    }
    return _swatches;
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
        if(pointer.dy < y || pointer.dy > y + height) {
          close();
        }
      }
    }
  }

  void open(BuildContext context) {
    _isOpening = true;
    _controllers.add(AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 150),
    ));
    final Widget overlay = Positioned(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      bottom: (MediaQuery.of(context).size.height * 0.1) - 3,
      left: 0,
      child: FadeTransition(
        opacity: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controllers.last,
            curve: Curves.easeInOutCirc,
          ),
        ),
        child: Container(
          color: theme.primaryColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder(
                  future: _swatchesFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return buildSwatchList(
                      context,
                      snapshot,
                      _swatchIcons,
                      axis: Axis.horizontal,
                      crossAxisCount: 1,
                      padding: 20,
                      spacing: 15,
                    );
                  },
                ),
                /*ListView.separated(
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
                ),*/
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
      ),
    );
    _controllers.last.forward();
    _overlayEntries.add(OverlayEntry(builder: (BuildContext context) => overlay));
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntries.last);
    Future.delayed(const Duration(milliseconds: 1000), () { _isOpening = false; });
  }

  void close() {
    if(_overlayEntries.length > 0 && !_isOpening) {
      for(int i = 0; i < _controllers.length; i++) {
        _controllers[i].reverse();
      }
      Future.delayed(
        const Duration(milliseconds: 200),
        () {
          for(int i = 0; i < _overlayEntries.length; i++) {
            _overlayEntries[i]?.remove();
          }
          _overlayEntries = [];
          _controllers.clear();
        }
      );
    }
  }

  @override
  void sortSwatches(String val) {
    _swatchesFuture = IO.sort(_swatches, (a, b) => a.compareTo(b, (swatch) => globals.distanceSortOptions(IO.getMultiple([_swatches]), currSwatch.color, step: 8)[val](swatch, 0)));
  }
}