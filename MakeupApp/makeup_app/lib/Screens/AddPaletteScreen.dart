import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'dart:math';
import '../Widgets/BorderBox.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorProcessingTF.dart';

class AddPaletteScreen extends StatefulWidget {
  final void Function(List<Swatch>) save;

  AddPaletteScreen(this.save);

  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();
}

class AddPaletteScreenState extends State<AddPaletteScreen> {
  GlobalKey _imgKey = GlobalKey();
  GlobalKey _borderKey = GlobalKey();
  GlobalKey _borderKeysParent = GlobalKey();

  int numCols = 1;
  int numRows = 1;
  String palette = '';

  List<double> borders = [0, 0, 0, 0];
  List<double> padding = [10, 10];
  List<double> imgSize = [0, 0];

  int _draggingCorner = 0;
  Offset _lastPos = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  initialValue: '1',
                  onChanged: (String val) { numCols = _toInt(val); },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  initialValue: '1',
                  onChanged: (String val) { numRows = _toInt(val); },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  initialValue: 'Palette Name',
                  onChanged: (String val) { palette = val; },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 35),
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: save,
                  child: Text(
                    'Save',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: GestureDetector(
                onPanStart: onDragStart,
                child: Stack(
                  children: <Widget>[
                    Image(
                      key: _imgKey,
                      image: AssetImage('imgs/test0.jpg'),
                    ),
                    GestureDetector(
                      onPanUpdate: (DragUpdateDetails drag) { onBordersChange(drag, _borderKey.currentWidget); },
                      child: BorderBox(
                        key: _borderKey,
                        width: 1,
                        height: 1,
                        borderWidth: 2,
                        borderColor: Colors.black,
                        padding: EdgeInsets.fromLTRB(borders[0], borders[1], borders[2], borders[3]),
                      ),
                    ),
                    Stack(
                      key: _borderKeysParent,
                      children: [
                        for(int i = 0; i < numCols; i++) Column(
                          children: [
                            for(int j = 0; j < numRows; j++) GestureDetector(
                              onPanUpdate: (DragUpdateDetails drag) { onPaddingChange(drag, find.descendant(of: find.byKey(_borderKeysParent), matching: find.byType(BorderBox)).at(j * numCols + i).evaluate().single.widget); },
                              child: BorderBox(
                                width: 1,
                                height: 1,
                                borderWidth: 2,
                                borderColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: padding[0], horizontal: padding[1]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDragStart(DragStartDetails drag) {
    _lastPos = drag.globalPosition;
  }

  void getDraggingCorner(DragUpdateDetails drag, BorderBox border) {
    Offset borderPos = border.getPos();
    double midX = borderPos.dx + (border.width / 2);
    double midY = borderPos.dy + (border.height / 2);
    Offset pos = drag.globalPosition;
    if(pos.dx >= midX && pos.dy >= midY) {
      _draggingCorner = 0;
    } else if(pos.dx >= midX && pos.dy < midY) {
      _draggingCorner = 1;
    } else if(pos.dx < midX && pos.dy >= midY) {
      _draggingCorner = 2;
    } else if(pos.dx < midX && pos.dy < midY) {
      _draggingCorner = 3;
    }
  }

  bool isDraggingPadding(Offset pos) {
    double width = (_imgKey.currentWidget as Image).width;
    double height = (_imgKey.currentWidget as Image).height;
    List<double> localBorders = [borders[0] + width, height + imgSize[1] - borders[1], width + imgSize[0] - borders[2], borders[3] + height];
    switch(_draggingCorner) {
      case 0:
        return (localBorders[2] - pos.dx) > (padding[0] - 1) && (localBorders[1] - pos.dy) > (padding[1] - 1);
      case 1:
        return (localBorders[2] - pos.dx) > (padding[0] - 1) && (pos.dy - localBorders[3]) > (padding[1] - 1);
      case 2:
        return (pos.dx - localBorders[0]) > (padding[0] - 1) && (localBorders[1] - pos.dy) > (padding[1] - 1);
      case 3:
        return (pos.dx - localBorders[0]) > (padding[0] - 1) && (pos.dy - localBorders[3]) > (padding[1] - 1);
    }
    return false;
  }

  void onBordersChange(DragUpdateDetails drag, BorderBox border) {
    if(!isDraggingPadding(drag.globalPosition)) {
      getDraggingCorner(drag, border);
      List<double> diff = [drag.globalPosition.dx - _lastPos.dx, drag.globalPosition.dy - _lastPos.dy];
      switch(_draggingCorner) {
        case 0:
          borders[2] -= diff[0];
          borders[1] -= diff[1];
          break;
        case 1:
          borders[2] -= diff[0];
          borders[3] += diff[1];
          break;
        case 2:
          borders[0] += diff[0];
          borders[1] -= diff[1];
          break;
         case 3:
          borders[0] += diff[0];
          borders[3] += diff[1];
          break;
      }
      (_borderKey.currentWidget as BorderBox).width = imgSize[0] - (borders[0] + borders[2]);
      (_borderKey.currentWidget as BorderBox).height = imgSize[1] - (borders[1] + borders[3]);
      updatePadding();
      _lastPos = drag.globalPosition;
    }
  }

  void onPaddingChange(DragUpdateDetails drag, BorderBox border) {
    if(isDraggingPadding(drag.globalPosition)) {
      getDraggingCorner(drag, border);
      List<double> diff = [drag.globalPosition.dx - _lastPos.dx, drag.globalPosition.dy - _lastPos.dy];
      switch (_draggingCorner) {
        case 0:
          borders[0] -= diff[0];
          borders[1] -= diff[1];
          break;
        case 1:
          borders[0] -= diff[0];
          borders[1] += diff[1];
          break;
        case 2:
          borders[0] += diff[0];
          borders[1] -= diff[1];
          break;
        case 3:
          borders[0] += diff[0];
          borders[1] += diff[1];
          break;
      }
      updatePadding();
      _lastPos = drag.globalPosition;
    }
  }

  void save() {
    image.Image img = loadImg((_imgKey.currentWidget as FileImage).file.path);
    double scale = (_imgKey.currentWidget as FileImage).scale;
    List<Swatch> swatches = List<Swatch>();
    List<double> borders = [this.borders[0] * scale, this.borders[1] * scale, this.borders[2] * scale, this.borders[3] * scale];
    List<double> padding = [this.padding[0] * scale, this.padding[1] * scale];
    double width = img.width - (borders[0] + borders[2]);
    double boxWidth = width / numCols;
    double height = img.height - (borders[1] + borders[3]);
    double boxHeight = height / numRows;
    for(int i = 0; i < numCols; i++) {
      for (int j = 0; j < numRows; j++) {
        int x = (borders[0] + (boxWidth * i) + padding[0]).round();
        int y = (borders[1] + (boxHeight * j) + padding[1]).round();
        int w = ((boxWidth * (i + 1)) - padding[0]).round();
        int h = ((boxHeight * (j + 1)) - padding[1]).round();
        image.Image cropped = image.copyCrop(img, x, y, w, h);
        getFinish(cropped).then((String finish) {
          swatches.add(Swatch(avgColor(cropped), finish, palette));
        });
      }
    }
    widget.save(swatches);
  }

  void updatePadding() {
    double maxX = (((_borderKey.currentWidget as BorderBox).width / numCols) - 5) / 2;
    double maxY = (((_borderKey.currentWidget as BorderBox).height / numRows) - 5) / 2;
    padding = [max(min(padding[0], maxX), 5), max(min(padding[1], maxY), 5)];
  }

  int _toInt(String val) {
    if(val == '' || int.parse(val) == 0) {
      return 1;
    }
    return int.parse(val);
  }
}
