import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:makeupapp/main.dart';
import 'dart:math';
import '../Widgets/BorderBox.dart';
import '../Widgets/Swatch.dart';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorProcessingTF.dart';
import '../ColorMath/ColorObjects.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;

class AddPaletteScreen extends StatefulWidget {
  final void Function(List<Swatch>) save;

  AddPaletteScreen(this.save);

  @override
  AddPaletteScreenState createState() => AddPaletteScreenState();
}

class AddPaletteScreenState extends State<AddPaletteScreen> {
  GlobalKey _imgKey = GlobalKey();
  GlobalKey _borderKey = GlobalKey();
  List<GlobalKey> _borderKeys = [];

  int numCols = 1;
  int numRows = 1;
  String palette = '';
  String imgPath;

  List<double> borders = [0, 0, 0, 0];
  List<double> padding = [5, 5];

  int _draggingCorner = 0;

  @override
  Widget build(BuildContext context) {
    imgPath = 'imgs/test0.jpg';
    Size imgSize = _getImgSize();
    Offset pos = _getImgPos();
    double width = imgSize.width;
    double boxWidth = (width - (borders[0] + borders[2])) / numCols;
    double height = imgSize.height;
    double boxHeight = (height - (borders[1] + borders[3])) / numRows;
    _borderKeys.clear();
    for(int i = 0; i < numCols; i++) {
      for(int j = 0; j < numRows; j++) {
        _borderKeys.add(GlobalKey());
      }
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.bgColor,
        resizeToAvoidBottomInset: false,
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
                  decoration: InputDecoration(
                    labelText: 'Number of Palette Columns',
                    labelStyle: theme.primaryText,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  initialValue: '1',
                  onChanged: (String val) { setState(() { numCols = _toInt(val); }); },
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
                  decoration: InputDecoration(
                    labelText: 'Number of Palette Rows',
                    labelStyle: theme.primaryText,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  initialValue: '1',
                  onChanged: (String val) { setState(() { numRows = _toInt(val); }); },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: 'Palette Name',
                    labelStyle: theme.primaryText,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) { palette = val; },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 35),
                child: FlatButton(
                  color: theme.accentColor,
                  onPressed: save,
                  child: Text(
                    'Save',
                    style: theme.accentText,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment(0, 0),
                    child: Image(
                      key: _imgKey,
                      image: AssetImage(imgPath),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0),
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails drag) { onBordersChange(drag, _borderKey.currentWidget); },
                      child: BorderBox(
                        key: _borderKey,
                        width: width,
                        height: height,
                        borderWidth: 2,
                        borderColor: Colors.black,
                        padding: EdgeInsets.fromLTRB(borders[0], borders[1], borders[2], borders[3]),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0),
                    child: Stack(
                      children: [
                        for(int i = 0; i < numCols; i++) for(int j = 0; j < numRows; j++) GestureDetector(
                          onPanUpdate: (DragUpdateDetails drag) { onPaddingChange(drag, _borderKeys[j * numCols + i].currentWidget); },
                          child: BorderBox(
                            key: _borderKeys[j * numCols + i],
                            width: boxWidth,
                            height: boxHeight,
                            borderWidth: 2,
                            borderColor: Colors.black,
                            offset: EdgeInsets.fromLTRB(
                              (i * boxWidth) + borders[0] + pos.dx,
                              (j * boxHeight) + borders[1] + ((pos.dy - height) / 2),
                              width - ((i + 1) * boxWidth) - borders[0] + pos.dx,
                              height - ((j + 1) * boxHeight) - borders[1] + ((pos.dy - height) / 2),
                            ),
                            padding: EdgeInsets.symmetric(vertical: padding[0], horizontal: padding[1]),
                          ),
                        ),
                      ],
                    ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getDraggingCorner(DragUpdateDetails drag, BorderBox border) {
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

  Size _getImgSize() {
    if(_imgKey != null && _imgKey.currentContext != null) {
      RenderBox renderBox = _imgKey.currentContext.findRenderObject();
      return renderBox.size;
    }
    return Size.zero;
  }

  Offset _getImgPos() {
    if(_imgKey != null && _imgKey.currentContext != null) {
      RenderBox renderBox = _imgKey.currentContext.findRenderObject();
      return renderBox.localToGlobal(Offset.zero);
    }
    return Offset.zero;
  }

  void onBordersChange(DragUpdateDetails drag, BorderBox border) {
    _getDraggingCorner(drag, border);
    switch(_draggingCorner) {
      case 0:
        borders[2] -= drag.delta.dx;
        borders[3] -= drag.delta.dy;
        break;
      case 1:
        borders[2] -= drag.delta.dx;
        borders[1] += drag.delta.dy;
        break;
      case 2:
        borders[0] += drag.delta.dx;
        borders[3] -= drag.delta.dy;
        break;
      case 3:
        borders[0] += drag.delta.dx;
        borders[1] += drag.delta.dy;
        break;
    }
    _updateBorders();
    _updatePadding();
  }

  void onPaddingChange(DragUpdateDetails drag, BorderBox border) {
    _getDraggingCorner(drag, border);
    switch(_draggingCorner) {
      case 0:
        padding[0] -= drag.delta.dx;
        padding[1] -= drag.delta.dy;
        break;
      case 1:
        padding[0] -= drag.delta.dx;
        padding[1] += drag.delta.dy;
        break;
      case 2:
        padding[0] += drag.delta.dx;
        padding[1] -= drag.delta.dy;
        break;
      case 3:
        padding[0] += drag.delta.dx;
        padding[1] += drag.delta.dy;
        break;
    }
    _updateBorders();
    _updatePadding();
  }

  void _updateBorders() {
    borders[0] = max(borders[0], 0);
    borders[1] = max(borders[1], 0);
    borders[2] = max(borders[2], 0);
    borders[3] = max(borders[3], 0);
    BorderBox borderBox = _borderKey.currentWidget as BorderBox;
    borderBox.padding = EdgeInsets.fromLTRB(borders[0], borders[1], borders[2], borders[3]);
    (_borderKey.currentState as BorderBoxState).update();
  }

  void _updatePadding() {
    BorderBox borderBox = _borderKey.currentWidget as BorderBox;
    double width = borderBox.width;
    double boxWidth = (width - (borders[0] + borders[2])) / numCols;
    double height = borderBox.height;
    double boxHeight = (height - (borders[1] + borders[3])) / numRows;
    double maxX = (boxWidth - 5) / 2;
    double maxY = (boxHeight - 5) / 2;
    padding = [max(min(padding[0], maxX), 5), max(min(padding[1], maxY), 5)];
    Size imgSize = _getImgSize();
    Offset imgPos = _getImgPos();
    for(int i = 0; i < numCols; i++) {
      for(int j = 0; j < numRows; j++) {
        BorderBox subBorderBox = (_borderKeys[j * numCols + i].currentWidget as BorderBox);
        subBorderBox.width = boxWidth;
        subBorderBox.height = boxHeight;
        subBorderBox.offset = EdgeInsets.fromLTRB(
            (i * boxWidth) + borders[0] + imgPos.dx,
            (j * boxHeight) + borders[1] + ((imgPos.dy - imgSize.height) / 2),
            width - ((i + 1) * boxWidth) - borders[0] + imgPos.dx,
            height - ((j + 1) * boxHeight) - borders[1] + ((imgPos.dy - imgSize.height) / 2),
        );
        subBorderBox.padding = EdgeInsets.fromLTRB(padding[0], padding[1], padding[0], padding[1]);
        (_borderKeys[j * numCols + i].currentState as BorderBoxState).update();
      }
    }
  }

  void save() async {
    await getModel();
    image.Image img = await loadImg(imgPath);
    List<Swatch> swatches = List<Swatch>();
    double width = img.width - (borders[0] + borders[2]);
    double boxWidth = width / numCols;
    double height = img.height - (borders[1] + borders[3]);
    double boxHeight = height / numRows;
    for(int i = 0; i < numCols; i++) {
      for(int j = 0; j < numRows; j++) {
        int x = (borders[0] + (boxWidth * i) + padding[0]).floor();
        //top
        int y = (borders[1] + (boxHeight * j) + padding[1]).floor();
        //bottom
        //int y = (borders[3] + (boxHeight * (numRows - j - 1)) + padding[1]).floor();
        image.Image cropped = image.copyCrop(img, x, y, (boxWidth - (padding[0] * 2)).floor(), (boxHeight - (padding[1] * 2)).floor());
        RGBColor color = avgColor(cropped);
        String finish = await getFinish(cropped);
        swatches.add(Swatch(color, finish, palette));
        print('${swatches.last.color.getValues()} $finish');
      }
    }
    widget.save(swatches);
    MakeupApp.hasSaveChanged = true;
    Navigator.pushReplacement(context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1500),
        pageBuilder: (context, animation, secondaryAnimation) { return routes.routes['/main0Screen'](context); },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween(
              begin: 1.0,
              end: 0.0,
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
  }

  int _toInt(String val) {
    if(val == '' || int.parse(val) == 0) {
      return 1;
    }
    return int.parse(val);
  }
}
