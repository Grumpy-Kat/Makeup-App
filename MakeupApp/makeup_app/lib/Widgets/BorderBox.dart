import 'package:flutter/material.dart';

class BorderBox extends StatefulWidget {
  BorderBox({ Key key, this.width = 1, this.height = 1, this.borderWidth = 1, this.borderColor, this.padding }) : super(key: key);

  GlobalKey _key = GlobalKey();

  double width;
  double height;
  double borderWidth;
  Color borderColor;
  EdgeInsets padding;

  @override
  BorderBoxState createState() => BorderBoxState();

  Offset getPos() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    return renderBox.localToGlobal(Offset.zero);
  }
}

class BorderBoxState extends State<BorderBox> {
  @override
  Widget build(BuildContext context) {
    if(widget.borderColor == null) {
      widget.borderColor = Theme.of(context).primaryColor;
    }
    print('${widget.width} ${widget.height} ${widget.padding} ${widget.borderWidth} ${widget.getPos()}');
    return SizedBox(
      key: widget._key,
      width: widget.width,
      height: widget.height,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          border: Border.all(
            width: widget.borderWidth,
            color: widget.borderColor,
          )
        ),
      ),
    );
  }
}