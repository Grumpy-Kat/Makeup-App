import 'package:flutter/material.dart' hide FlatButton;
import 'package:flutter/gestures.dart';
import '../Screens/SwatchScreen.dart';
import '../ColorMath/ColorProcessing.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../navigation.dart' as navigation;
import '../types.dart';
import '../Data/Swatch.dart';
import 'FlatButton.dart';

class InfoBox extends StatefulWidget {
  static Size? screenSize;

  final Swatch? swatch;

  final OnVoidAction? onTap;
  final OnVoidAction? onDoubleTap;

  final Widget? child;
  final GlobalKey? childKey;

  final bool showMoreBtn;

  InfoBox({ GlobalKey? key, required this.swatch, this.onTap, this.onDoubleTap, this.child, this.childKey, this.showMoreBtn = true }) : super(key: key);

  @override
  InfoBoxState createState() => InfoBoxState();
}

class InfoBoxState extends State<InfoBox> with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;

  bool _hasSetValues = false;
  String _colorName = '';
  String _finish = '';
  String _brand = '';
  String _palette = '';
  String _shade = '';

  Size? _size;
  late Size _arrowSize;
  Offset? _pos;
  Offset? _arrowPos;
  double? _verticalOffset;

  bool _shouldClose = false;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance!.pointerRouter.addGlobalRoute(onPointerEvent);
    _arrowSize = const Size(10, 15);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    setValues();
  }

  void setValues() {
    Swatch? swatch = widget.swatch;
    if(swatch != null) {
      _hasSetValues = true;
      String colorName = swatch.colorName;
      _colorName = globalWidgets.toTitleCase(colorName == '' ? getString(getColorName(swatch.color)) : (colorName.contains('color_') ? getString(colorName) : colorName));
      _finish = globalWidgets.toTitleCase(getString(swatch.finish));
      _brand = globalWidgets.toTitleCase(swatch.brand);
      _palette = globalWidgets.toTitleCase(swatch.palette);
      _shade = globalWidgets.toTitleCase(swatch.shade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: widget.child,
    );
  }

  void onPointerEvent(PointerEvent event) {
    if(_overlayEntry == null) {
      return;
    }
    if(event is PointerUpEvent || event is PointerCancelEvent || event is PointerDownEvent) {
      if(_size != null && _pos != null) {
        Offset pointer = event.position;
        if(pointer.dx < _pos!.dx || pointer.dy < _pos!.dy || pointer.dx > _pos!.dx + _size!.width || pointer.dy > _pos!.dy + _size!.height) {
          close();
          return;
        } else if(_shouldClose){
          _shouldClose = false;
          close();
        }
      }
    }
  }

  void open() {
    if(!_hasSetValues) {
      setValues();
    }
    RenderBox? renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
    Offset pos;
    if(renderBox != null) {
      pos = renderBox.localToGlobal(Offset.zero);
    } else {
      pos = Offset.zero;
    }
    RenderBox? childRenderBox = _key.currentContext!.findRenderObject() as RenderBox?;
    Offset childPos;
    Size childSize;
    if(childRenderBox != null) {
      childPos = childRenderBox.localToGlobal(Offset.zero);
      childSize = childRenderBox.size;
    } else {
      childPos = Offset.zero;
      childSize = Size.zero;
    }
    //this sizing won't work if both shade is not filled and not showing "More..." button
    //the setting is only currently used in preset palettes so it is not currently an issue
    _size = Size(InfoBox.screenSize!.width * 0.9, ((_shade != '' && widget.showMoreBtn) ? 147 : 135));
    _verticalOffset = childSize.height + 5;
    bool isFlipped = false;
    if(pos.dy > 500) {
      //flipped arrow
      isFlipped = true;
      //5 is extra space added to _verticalOffset
      _pos = Offset(InfoBox.screenSize!.width * 0.05, pos.dy - _size!.height - (_arrowSize.height * 2) - 5);
      _arrowPos = Offset(childPos.dx + (childSize.width / 2) - (InfoBox.screenSize!.width * 0.05), (_arrowSize.height * 2) + _size!.height);
    } else {
      //regular arrow
      isFlipped = false;
      _pos = Offset(InfoBox.screenSize!.width * 0.05, pos.dy + _verticalOffset!);
      //childPos.dx is left corner of swatch
      //(childSize.width / 2) is midway point of swatch
      //(InfoBox.screenSize.width * 0.05) is offset of box
      _arrowPos = Offset(childPos.dx + (childSize.width / 2) - (InfoBox.screenSize!.width * 0.05), 0);
    }
    final Widget overlay = Positioned(
      width: _size!.width,
      height: _size!.height + _arrowSize.height,
      left: _pos!.dx,
      top: _pos!.dy,
      child: FadeTransition(
        opacity: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOutCirc,
          ),
        ),
        child: Column(
          children: <Widget> [
            Container(
              color: theme.primaryColorDark,
              child: Align(
                alignment: const Alignment(-1, -1),
                child: CustomPaint(
                painter: TrianglePainter(
                  size: _arrowSize,
                  pos: _arrowPos!,
                  color: theme.primaryColorDark,
                  isFlipped: isFlipped,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: _arrowSize.height),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                color: theme.primaryColorDark,
                child: Column(
                  children: <Widget>[
                    getText('${getString('infoBox_color')} $_colorName'),
                    getText('${getString('infoBox_finish')} $_finish'),
                    getText('${getString('infoBox_brand')} $_brand'),
                    getText('${getString('infoBox_palette')} $_palette'),
                    if(_shade != '') getText('${getString('infoBox_shade')} $_shade'),
                    if(widget.showMoreBtn) Expanded(
                      flex: 4,
                      child: Align(
                        alignment: const Alignment(-1, -1),
                        child: FlatButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            _shouldClose = true;
                            navigation.push(
                              context,
                              const Offset(1, 0),
                              routes.ScreenRoutes.SwatchScreen,
                              SwatchScreen(swatch: widget.swatch!.id),
                            );
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              getString('infoBox_more'),
                              style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: theme.fontFamily),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    _controller.forward();
    _overlayEntry = OverlayEntry(builder: (BuildContext context) => overlay);
    Overlay.of(context, debugRequiredFor: widget)!.insert(_overlayEntry!);
  }

  Widget getText(String text) {
    return Expanded(
      flex: 3,
      child: Align(
        alignment: const Alignment(-1, -1),
        child: Text(
          text,
          style: theme.primaryTextSecondary,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  void close() {
    _controller.reverse();
    Future.delayed(
      _controller.duration!,
      () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    );
  }
}

class TrianglePainter extends CustomPainter {
  late Paint _paint;

  Size size;
  Offset pos;
  Color color;

  bool isFlipped;

  TrianglePainter({ required this.size, required this.pos, required this.color, this.isFlipped = true }) {
    _paint = Paint();
    _paint.color = this.color;
    _paint.strokeJoin = StrokeJoin.bevel;
    _paint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    if(isFlipped) {
      path.moveTo(pos.dx - this.size.width, pos.dy - this.size.height);
      path.lineTo(pos.dx, pos.dy);
      path.lineTo(pos.dx + this.size.width, pos.dy - this.size.height);
    } else {
      path.moveTo(pos.dx - this.size.width, pos.dy + this.size.height);
      path.lineTo(pos.dx, pos.dy);
      path.lineTo(pos.dx + this.size.width, pos.dy + this.size.height);
    }
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}