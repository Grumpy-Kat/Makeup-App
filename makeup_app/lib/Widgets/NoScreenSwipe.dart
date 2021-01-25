import 'package:flutter/material.dart';
import 'dart:math';
import '../Screens/Screen.dart';

class NoScreenSwipe extends StatefulWidget {
  final ScreenState parent;
  final Widget child;

  NoScreenSwipe({ Key key, this.parent, this.child }) : super(key: key);

  @override
  NoScreenSwipeState createState() => NoScreenSwipeState();
}

class NoScreenSwipeState extends State<NoScreenSwipe> {
  GlobalKey key = GlobalKey();

  Rectangle<double> bounds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        RenderBox renderBox = key.currentContext.findRenderObject();
        Offset pos = renderBox.localToGlobal(Offset.zero);
        Size size = renderBox.size;
        bounds = Rectangle<double>(pos.dx, pos.dy, size.width, size.height);
        widget.parent.noScreenSwipes.add(bounds);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.parent.noScreenSwipes.remove(bounds);
    super.dispose();
  }
}
