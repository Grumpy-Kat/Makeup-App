import 'package:GlamKit/Widgets/Filter.dart';
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
  static Size screenSize;

  RecommendedSwatchBar({ Key key }) : super(key: key);

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

  Size _size;
  Offset _pos;

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
    _size = Size(RecommendedSwatchBar.screenSize.width, RecommendedSwatchBar.screenSize.height * 0.1);
    _pos = Offset(0, _size.height);
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
    _swatchIcons.clear();
    Map<int, int> occurrences = {};
    for(int i = 0; i < currSwatches.length; i++) {
      Map<Swatch, int> similarSwatches = getSimilarColors(
        currSwatch.color,
        currSwatch,
        IO.getMany(allSwatches),
        maxDist: 10,
        getSimilar: true,
        getOpposite: true,
      );
      similarSwatches.forEach(
        (Swatch key, int value) {
          int id = IO.find(key);
          if(currSwatches.contains(id)) {
            //skip swatches that are already in Today's Look
            return;
          }
          if(occurrences.containsKey(id)) {
            occurrences[id] += value;
          } else {
            occurrences[id] = value + key.rating;
          }
        }
      );
    }
    List<int> recommendedSwatches = occurrences.keys.toList(growable: false);
    recommendedSwatches.sort((a, b) => occurrences[b].compareTo(occurrences[a]));
    maxSwatches = min(maxSwatches, recommendedSwatches.length);
    for(int i = 0; i < maxSwatches; i++) {
      if(recommendedSwatches[i] != null) {
        _swatches.add(recommendedSwatches[i]);
        _swatchIcons.add(SwatchIcon.id(recommendedSwatches[i], showInfoBox: true));
      }
    }
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    //print(MediaQuery.of(context).padding.bottom);
    //MediaQuery does not work in init
    //_pos = Offset(0, _size.height +  MediaQuery.of(context).padding.bottom);
    return Container(
      width: 0,
      height: 0,
    );
  }

  void onPointerEvent(PointerEvent event) {
    if(event is PointerUpEvent || event is PointerCancelEvent || event is PointerDownEvent) {
      if(context != null) {
        //event.position goes top to bottom, _pos and _size go bottom to top
        Offset pointer = Offset(MediaQuery.of(context).size.width - event.position.dx, MediaQuery.of(context).size.height - event.position.dy);
        if(pointer.dy < _pos.dy || pointer.dy > _pos.dy + _size.height) {
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
      width: _size.width,
      height: _size.height,
      left: _pos.dx,
      bottom: _pos.dy,
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
      for(int i = 0; i < _overlayEntries.length; i++) {
        _overlayEntries[i]?.remove();
      }
      _overlayEntries = [];
      _controllers.clear();
    }
  }

  @override
  Future<void> deleteSwatches() async {
    //do nothing
  }

  @override
  void sortSwatches(String val) {
    _swatchesFuture = IO.sort(_swatches, (a, b) => a.compareTo(b, (swatch) => globals.distanceSortOptions(IO.getMultiple([_swatches]), currSwatch.color, step: 16)[val](swatch, 0)));
  }

  @override
  void filterSwatches(List<Filter> filters) {
    _swatchesFuture = IO.filter(_swatches, filters);
  }

  @override
  Future<List<int>> sortAndFilterSwatchesActual() async {
    _swatches = await IO.sort(_swatches, (a, b) => a.compareTo(b, (swatch) => swatchList.sort[currentSort](swatch, 0)));
    return await IO.filter(_swatches, filters);
  }
}