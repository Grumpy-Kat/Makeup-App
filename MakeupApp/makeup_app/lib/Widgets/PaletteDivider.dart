import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'dart:math';
import 'dart:io';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorProcessingTF.dart';
import '../ColorMath/ColorObjects.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../types.dart';
import 'ImagePicker.dart';
import 'BorderBox.dart';
import 'Swatch.dart';

class PaletteDivider extends StatefulWidget {
  final void Function(List<Swatch>) onEnter;

  PaletteDivider({Key key, @required this.onEnter}) : super(key: key);

  @override
  PaletteDividerState createState() => PaletteDividerState();
}

class PaletteDividerState extends State<PaletteDivider> {
  GlobalKey _imgKey = GlobalKey();
  GlobalKey _borderKey = GlobalKey();
  List<GlobalKey> _borderKeys = [];

  Size imgSize;
  Future<Size> actualImg;

  int numCols = 1;
  int numRows = 1;

  TextEditingController colsController;
  TextEditingController rowsController;

  List<double> borders = [0, 0, 0, 0];
  List<double> padding = [5, 5];

  int _draggingCorner = 0;

  List<Swatch> _swatches;

  @override
  void initState() {
    super.initState();
    ImagePicker.img = null;
    actualImg = ImagePicker.getActualImgSize(ImagePicker.img);
    colsController = TextEditingController(text: numCols.toString());
    rowsController = TextEditingController(text: numRows.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: actualImg,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //determine properties
        bool showImg = false;
        double topPadding = 15;
        Size screenSize = MediaQuery.of(context).size;
        Size maxSize = Size(screenSize.width * 0.9, (screenSize.height * 0.5) - topPadding);
        Size actualImg = Size(50, 50);
        imgSize = Size(50, 50);
        if(ImagePicker.img != null && snapshot.connectionState == ConnectionState.done) {
          showImg = true;
          if(globals.debug) {
            actualImg = Size(355, 355);
          } else {
            actualImg = snapshot.data;
          }
          imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
        }
        double width = imgSize.width;
        double boxWidth = (width - (borders[0] + borders[2])) / numCols;
        double height = imgSize.height;
        double boxHeight = (height - (borders[1] + borders[3])) / numRows;
        //fill borderKeys
        _borderKeys.clear();
        for(int i = 0; i < numCols; i++) {
          for(int j = 0; j < numRows; j++) {
            _borderKeys.add(GlobalKey());
          }
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.focusedChild.unfocus();
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(
              children: <Widget>[
                getPickImgBtn(),
                if(!showImg) Container(
                  alignment: Alignment(0, -0.77),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'If the palette does not have uniform columns and rows, try to add it in sections.',
                    style: theme.primaryTextSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Align(
                  alignment: Alignment(0, -0.77),
                  child: getAnimatedOpacity(
                    showImg,
                    child: Row(
                      children: <Widget>[
                        getTextField(screenSize, 'Palette Columns', colsController, (String val) { setState(() { numCols = _toInt(val); }); }),
                        getTextField(screenSize, 'Palette Rows', rowsController, (String val) { setState(() { numRows = _toInt(val); }); })
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: getAnimatedOpacity(
                    showImg,
                    child: Stack(
                      children: <Widget>[
                        getImg(),
                        getOuterBorder(width, height),
                        getInnerBorders(width, height, boxWidth, boxHeight),
                      ],
                    ),
                  ),
                ),
                getEnterBtn(showImg),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget getAnimatedOpacity(bool showImg, { @required Widget child }) {
    return AnimatedOpacity(
      opacity: (showImg ? 1 : 0),
      duration: Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget getTextField(Size screenSize, String label, TextEditingController controller, OnStringAction onStringAction) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: (screenSize == null ? 175 : screenSize.width / 2),
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        style: theme.primaryTextSmall,
        cursorColor: theme.accentColor,
        controller: controller,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          labelText: label,
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
        onChanged: onStringAction,
      ),
    );
  }

  Widget getPickImgBtn() {
    return Align(
      alignment: Alignment(0, -1),
      child: FlatButton(
        color: (ImagePicker.img == null ? theme.accentColor : theme.primaryColorDark),
        onPressed: () {
          ImagePicker.open(context).then(
            (val) {
              setState(() {
                this.actualImg = ImagePicker.getActualImgSize(ImagePicker.img);
                this.numCols = 1;
                this.colsController.value = TextEditingValue(
                  text: numCols.toString(),
                  selection: this.colsController.selection,
                );
                this.numRows = 1;
                this.rowsController.value = TextEditingValue(
                  text: numRows.toString(),
                  selection: this.rowsController.selection,
                );
                this.borders = [0, 0, 0, 0];
                this.padding = [5, 5];
              });
            }
          );
        },
        child: Text(
          'Add Image',
          style: (ImagePicker.img == null ? theme.accentText : theme.primaryText),
        ),
      ),
    );
  }

  Widget getEnterBtn(bool showImg) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: getAnimatedOpacity(
        showImg,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
    );
  }

  Widget getImg() {
    if(globals.debug) {
      //debug assumes to use a static image, instead of actual image picked
      return Align(
        alignment: Alignment(0, 0.4),
        child: Image.asset(
          'imgs/test0.jpg',
          key: _imgKey,
          width: imgSize.width,
          height: imgSize.height,
        ),
      );
    }
    //release mode uses actual image picked
    return Align(
      alignment: Alignment(0, 0.4),
      child: Image.file(
        (ImagePicker.img == null ? File('imgs/matte.png') : ImagePicker.img),
        key: _imgKey,
        width: imgSize.width,
        height: imgSize.height,
      ),
    );
  }

  Widget getOuterBorder(double width, double height) {
    return Align(
      alignment: Alignment(0, 0.4),
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails drag) { onBordersChange(drag, _borderKey.currentWidget); },
        child: BorderBox(
          key: _borderKey,
          width: width,
          height: height,
          borderWidth: 3,
          borderColor: Colors.black,
          padding: EdgeInsets.fromLTRB(borders[0], borders[1], borders[2], borders[3]),
        ),
      ),
    );
  }

  Widget getInnerBorders(double width, double height, double boxWidth, double boxHeight) {
    return Align(
      alignment: Alignment(0, 0.4),
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
                (i * boxWidth) + borders[0],
                (j * boxHeight) + borders[1],
                width - ((i + 1) * boxWidth) - borders[0],
                height - ((j + 1) * boxHeight) - borders[1],
              ),
              padding: EdgeInsets.fromLTRB(padding[0], padding[1], padding[0], padding[1]),
            ),
          ),
        ],
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
    _update();
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
    _update();
  }

  void _update() {
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
    double width = imgSize.width;
    double boxWidth = (width - (borders[0] + borders[2])) / numCols;
    double height = imgSize.height;
    double boxHeight = (height - (borders[1] + borders[3])) / numRows;
    double maxX = (boxWidth - 5) / 2;
    double maxY = (boxHeight - 5) / 2;
    padding = [max(min(padding[0], maxX), 5), max(min(padding[1], maxY), 5)];
    for(int i = 0; i < numCols; i++) {
      for(int j = 0; j < numRows; j++) {
        BorderBox subBorderBox = (_borderKeys[j * numCols + i].currentWidget as BorderBox);
        subBorderBox.width = boxWidth;
        subBorderBox.height = boxHeight;
        subBorderBox.offset = EdgeInsets.fromLTRB(
          (i * boxWidth) + borders[0],
          (j * boxHeight) + borders[1],
          width - ((i + 1) * boxWidth) - borders[0],
          height - ((j + 1) * boxHeight) - borders[1],
        );
        subBorderBox.padding = EdgeInsets.fromLTRB(padding[0], padding[1], padding[0], padding[1]);
        (_borderKeys[j * numCols + i].currentState as BorderBoxState).update();
      }
    }
  }

  void save() async {
    await getModel();
    _swatches = [];
    image.Image img;
    Size actualImg;
    if(globals.debug) {
     img = await loadImg('imgs/test0.jpg');
     actualImg = Size(355, 355);
    } else {
      img = await loadImg(ImagePicker.img.path);
      actualImg = await ImagePicker.getActualImgSize(ImagePicker.img);
    }
    double imgScale = imgSize.width / actualImg.width;
    double width = imgSize.width - (borders[0] + borders[2]);
    double boxWidth = width / numCols / imgScale;
    double height = imgSize.height - (borders[1] + borders[3]);
    double boxHeight = height / numRows / imgScale;
    List<double> scaledBorders = [borders[0] / imgScale, borders[1] / imgScale, borders[2] / imgScale, borders[3] / imgScale];
    List<double> scaledPadding = [padding[0] / imgScale, padding[1] / imgScale];
    for(int j = 0; j < numRows; j++) {
      for(int i = 0; i < numCols; i++) {
        int x = (scaledBorders[0] + (boxWidth * i) + scaledPadding[0]).floor();
        int y = (scaledBorders[1] + (boxHeight * j) + scaledPadding[1]).floor();
        int w = (boxWidth - (scaledPadding[0] * 2)).floor();
        int h = (boxHeight - (scaledPadding[1] * 2)).floor();
        //print('$x $w ${scaledPadding[0]} $width $numCols $imgScale ${imgSize.width} ${actualImg.width}');
        //print('$y $h ${scaledPadding[1]} $height $numRows $imgScale ${imgSize.height} ${actualImg.height}');
        image.Image cropped;
        if(img.width == actualImg.width) {
          //correct orientation
          cropped = crop(img, x, y, w, h);
        } else {
          //rotated orientation
          cropped = crop(img, y, x, h, w);
        }
        if(cropped == null) {
          return;
        }
        RGBColor color = avgColor(cropped);
        String finish = await getFinish(cropped);
        _swatches.add(Swatch(color: color, finish: finish, brand: '', palette: '', shade: '', rating: 5, tags: []));
        print('${_swatches.last.color.getValues()} $finish');
      }
    }
    widget.onEnter(_swatches);
  }

  image.Image crop(image.Image src, int x, int y, int w, int h) {
    image.Image dst = image.Image(w, h, channels: src.channels, exif: src.exif, iccp: src.iccProfile);
    for(int xi = 0, sx = x; xi < w; xi++, sx++) {
      for(int yi = 0, sy = y; yi < h; yi++, sy++) {
        try {
          dst.setPixel(xi, yi, src.getPixel(sx, sy));
        } catch(e) {
          print('$xi $yi $sx $sy');
          return null;
        }
      }
    }
    return dst;
  }

  int _toInt(String val) {
    if(val == '' || int.parse(val) == 0) {
      return 1;
    }
    return int.parse(val);
  }
}
