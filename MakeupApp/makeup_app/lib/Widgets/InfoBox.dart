import 'package:flutter/material.dart';

class InfoBox extends StatefulWidget {
  @override
  InfoBoxState createState() => InfoBoxState();
}

class InfoBoxState extends State<InfoBox> {
  String color = "";
  String finish = "";
  String palette = "";

  void updateInfo(color, finish, palette) {
    setState(() {
      this.color = color;
      this.finish = finish;
      this.palette = palette;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: Row(
        children: <Widget>[
        Expanded(
          child: Text('Color: $color'),
        ),
        Expanded(
          child: Text('Finish: $finish'),
        ),
        Expanded(
          child: Text('Palette: $palette'),
        ),
      ],
      ),
    );
  }
}