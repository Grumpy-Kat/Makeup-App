import 'package:flutter/material.dart';
import 'dart:math';
import '../theme.dart' as theme;

// ignore: must_be_immutable
class BorderBox extends StatefulWidget {
  final GlobalKey _key = GlobalKey();

  double width;
  double height;
  double borderWidth;
  Color? borderColor;
  EdgeInsets offset;
  EdgeInsets padding;

  BorderBox({ Key? key, this.width = 1, this.height = 1, this.borderWidth = 1, this.borderColor, this.offset = EdgeInsets.zero, this.padding = EdgeInsets.zero }) : super(key: key);

  @override
  BorderBoxState createState() => BorderBoxState();

  Offset getPos() {
    if(_key.currentContext != null) {
      RenderBox? renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
      if(renderBox != null) {
        return renderBox.localToGlobal(Offset.zero);
      }
    }
    return Offset.zero;
  }
}

class BorderBoxState extends State<BorderBox> {
  void update() {
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.borderColor == null) {
      widget.borderColor = theme.primaryColorDark;
    }
    widget.padding = maxEdges(widget.padding, EdgeInsets.zero)!;
    widget.offset = maxEdges(widget.offset, EdgeInsets.zero)!;
    //print('${widget.width} ${widget.height} ${widget.padding} ${widget.offset}');
    return Container(
      key: widget._key,
      margin: widget.offset,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          margin: widget.padding,
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              width: widget.borderWidth,
              color: widget.borderColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets? maxEdges(EdgeInsets? a, EdgeInsets? b) {
    if(a == null) {
      return null;
    }
    if(b == null) {
      return a;
    }
    return EdgeInsets.fromLTRB(
      max(a.left, b.left),
      max(a.top, b.top),
      max(a.right, b.right),
      max(a.bottom, b.bottom),
    );
  }

  EdgeInsets? minEdges(EdgeInsets? a, EdgeInsets? b) {
    if(a == null) {
      return null;
    }
    if(b == null) {
      return a;
    }
    return EdgeInsets.fromLTRB(
      min(a.left, b.left),
      min(a.top, b.top),
      min(a.right, b.right),
      min(a.bottom, b.bottom),
    );
  }
}