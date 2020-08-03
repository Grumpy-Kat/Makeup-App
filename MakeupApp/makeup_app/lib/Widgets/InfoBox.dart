import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme.dart' as theme;

class InfoBox extends StatefulWidget {
  static Size screenSize;

  final String color;
  final String finish;
  final String palette;

  final double verticalOffset;

  final void Function() onTap;
  final void Function() onDoubleTap;

  final Widget child;
  final int index;

  InfoBox({GlobalKey key, this.color = '', this.finish = '', this.palette = '', this.verticalOffset, this.onTap, this.onDoubleTap, this.child, this.index}) : super(key: key);

  @override
  InfoBoxState createState() => InfoBoxState();
}

class InfoBoxState extends State<InfoBox> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry _overlayEntry;

  int yIndex;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(onPointerEvent);
    yIndex = (widget.index / 3).floor();
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
    if(event is PointerUpEvent || event is PointerCancelEvent || event is PointerDownEvent) {
      close();
    }
  }

  //TODO: add fade in/out animation
  //TODO: test that works with new size
  void open() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    Offset pos = renderBox.localToGlobal(Offset.zero);
    Size size = Size(InfoBox.screenSize.width * 0.9, InfoBox.screenSize.height * 0.15);
    Size arrowSize = Size(10, 15);
    final Widget overlay = Positioned(
      width: size.width,
      height: size.height + arrowSize.width,
      top: pos.dy + widget.verticalOffset,
      left: InfoBox.screenSize.width * 0.05,
      child: IgnorePointer(
        child: Column(
          children: <Widget> [
            Container(
              color: theme.primaryColorDark,
              child: Align(
                alignment: Alignment(-1, -1),
                child: CustomPaint(
                painter: TrianglePainter(
                  size: arrowSize,
                  //pos: Offset(pos.dx + ((InfoBox.screenSize.width - 40) / 6) - 30, (renderBox.size.height * (yIndex + 1)) + (35 * yIndex) + 20 - size.height - (InfoBox.screenSize.width / 3 * yIndex)),
                  pos: Offset(pos.dx + ((InfoBox.screenSize.width - 40) / 6) - 30, (renderBox.size.height * (yIndex + 1)) + (36.5 * yIndex) + 20 - size.height - (InfoBox.screenSize.width / 3 * (yIndex))),
                  color: theme.primaryColorDark,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: arrowSize.height),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: theme.primaryColorDark,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          'Color: ${widget.color}',
                          style: theme.primaryText,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          'Finish: ${widget.finish}',
                          style: theme.primaryText,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          'Palette: ${widget.palette}',
                          style: theme.primaryText,
                          textAlign: TextAlign.left,
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
    _overlayEntry = OverlayEntry(builder: (BuildContext context) => overlay);
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry);
  }

  void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class TrianglePainter extends CustomPainter{
  Paint _paint;

  Size size;
  Offset pos;
  Color color;

  TrianglePainter({this.size, this.pos, this.color}) {
    _paint = Paint();
    _paint.color = this.color;
    _paint.strokeJoin = StrokeJoin.bevel;
    _paint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(pos.dx - this.size.width, pos.dy + this.size.height);
    path.lineTo(pos.dx, pos.dy);
    path.lineTo(pos.dx + this.size.width, pos.dy + this.size.height);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}