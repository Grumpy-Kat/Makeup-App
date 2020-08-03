import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/SingleSwatchList.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;

class Main0Screen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  Main0Screen(this.loadFormatted);

  @override
  Main0ScreenState createState() => Main0ScreenState();
}

class Main0ScreenState extends State<Main0Screen> with ScreenState {
  List<Swatch> _swatches = [];
  Future<List<Swatch>> _swatchesFuture;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
  }

  Future<List<Swatch>> _addSwatches() async {
    _swatches.clear();
    _swatches = await widget.loadFormatted();
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      widget.loadFormatted,
      0,
      SingleSwatchList(
        addSwatches: _swatchesFuture,
        updateSwatches: (List<Swatch> swatches) { this._swatches = swatches; },
        showNoColorsFound: false,
        showPlus: true,
        onPlusPressed: () {
          Navigator.pushReplacement(context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 1500),
              pageBuilder: (context, animation, secondaryAnimation) {
                return routes.routes['/addPaletteScreen'](context);
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return ScaleTransition(
                  scale: Tween(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCirc,
                    ),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        defaultSort: 'Color',
        sort: {
          'Color': (Swatch swatch) { return stepSort(swatch.color, step: 8); },
          'Finish': (Swatch swatch) { return finishSort(swatch, step: 8); },
          'Palette': (Swatch swatch) { return paletteSort(swatch, _swatches, step: 8); },
        },
      ),
    );
  }
}
