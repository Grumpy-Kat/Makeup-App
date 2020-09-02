import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Screens/SwatchScreen.dart';
import '../ColorMath/ColorProcessing.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import '../routes.dart' as routes;
import '../navigation.dart' as navigation;
import '../types.dart';
import 'Swatch.dart';

class InfoBox extends StatefulWidget {
  static Size screenSize;

  final Swatch swatch;

  //final double verticalOffset;

  final OnVoidAction onTap;
  final OnVoidAction onDoubleTap;

  final Widget child;
  final GlobalKey childKey;

  InfoBox({ GlobalKey key, @required this.swatch, this.onTap, this.onDoubleTap, this.child, this.childKey }) : super(key: key);

  @override
  InfoBoxState createState() => InfoBoxState();
}

class InfoBoxState extends State<InfoBox> with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  OverlayEntry _overlayEntry;

  AnimationController _controller;

  String _colorName;
  String _finish;
  String _brand;
  String _palette;
  String _shade;

  Size _size;
  Size _arrowSize;
  Offset _pos;
  Offset _arrowPos;
  double _verticalOffset;

  bool _shouldClose = false;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(onPointerEvent);
    _colorName = globalWidgets.toTitleCase(getColorName(widget.swatch.color));
    _finish = globalWidgets.toTitleCase(widget.swatch.finish);
    _brand = globalWidgets.toTitleCase(widget.swatch.brand);
    _palette = globalWidgets.toTitleCase(widget.swatch.palette);
    _shade = globalWidgets.toTitleCase(widget.swatch.shade);
    _arrowSize = Size(10, 15);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
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
        if(pointer.dx < _pos.dx || pointer.dy < _pos.dy || pointer.dx > _pos.dx + _size.width || pointer.dy > _pos.dy + _size.height) {
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
    RenderBox renderBox = _key.currentContext.findRenderObject();
    Offset pos = renderBox.localToGlobal(Offset.zero);
    RenderBox childRenderBox = _key.currentContext.findRenderObject();
    Offset childPos = childRenderBox.localToGlobal(Offset.zero);
    Size childSize = childRenderBox.size;
    _size = Size(InfoBox.screenSize.width * 0.9, (_shade != '' ? 140 :120));
    _verticalOffset = childSize.height + 5;
    bool isFlipped = false;
    if(pos.dy > 500) {
      //flipped arrow
      isFlipped = true;
      //5 is extra space added to _verticalOffset
      _pos = Offset(InfoBox.screenSize.width * 0.05, pos.dy - _size.height - (_arrowSize.height * 2) - 5);
      _arrowPos = Offset(childPos.dx + (childSize.width / 2) - (InfoBox.screenSize.width * 0.05), (_arrowSize.height * 2) + _size.height);
    } else {
      //regular arrow
      isFlipped = false;
      _pos = Offset(InfoBox.screenSize.width * 0.05, pos.dy + _verticalOffset);
      //childPos.dx is left corner of swatch
      //(childSize.width / 2) is midway point of swatch
      //(InfoBox.screenSize.width * 0.05) is offset of box
      _arrowPos = Offset(childPos.dx + (childSize.width / 2) - (InfoBox.screenSize.width * 0.05), 0);
    }
    final Widget overlay = Positioned(
      width: _size.width,
      height: _size.height + _arrowSize.height,
      left: _pos.dx,
      top: _pos.dy,
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
                alignment: Alignment(-1, -1),
                child: CustomPaint(
                painter: TrianglePainter(
                  size: _arrowSize,
                  pos: _arrowPos,
                  color: theme.primaryColorDark,
                  isFlipped: isFlipped,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: _arrowSize.height),
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                color: theme.primaryColorDark,
                child: Column(
                  children: <Widget>[
                    getText('Color: $_colorName'),
                    getText('Finish: $_finish'),
                    getText('Brand: $_brand'),
                    getText('Palette: $_palette'),
                    if(_shade != '') getText('Shade: $_shade'),
                    Expanded(
                      child: Align(
                        alignment: Alignment(-1, -1),
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            _shouldClose = true;
                            navigation.push(
                              context,
                              Offset(1, 0),
                              routes.ScreenRoutes.SwatchScreen,
                              SwatchScreen(swatch: widget.swatch.id),
                            );
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'More...',
                              style: theme.primaryTextSmallest,
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
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry);
  }

  Widget getText(String text) {
    return Expanded(
      child: Align(
        alignment: Alignment(-1, -1),
        child: Text(
          text,
          style: theme.primaryTextSmallest,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  void close() {
    _controller.reverse();
    Future.delayed(
      _controller.duration,
      () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    );
  }
}

class TrianglePainter extends CustomPainter{
  Paint _paint;

  Size size;
  Offset pos;
  Color color;

  bool isFlipped;

  TrianglePainter({ this.size, this.pos, this.color, this.isFlipped = true }) {
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