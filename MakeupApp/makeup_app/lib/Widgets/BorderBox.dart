import 'package:flutter/material.dart';
import '../theme.dart' as theme;

class BorderBox extends StatefulWidget {
  final GlobalKey _key = GlobalKey();

  double width;
  double height;
  double borderWidth;
  Color borderColor;
  EdgeInsets offset;
  EdgeInsets padding;

  BorderBox({ Key key, this.width = 1, this.height = 1, this.borderWidth = 1, this.borderColor, this.offset, this.padding }) : super(key: key);

  @override
  BorderBoxState createState() => BorderBoxState();

  Offset getPos() {
    if(_key != null && _key.currentContext != null) {
      RenderBox renderBox = _key.currentContext.findRenderObject();
      return renderBox.localToGlobal(Offset.zero);
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
              color: widget.borderColor,
            ),
          ),
        ),
      ),
    );
  }
}