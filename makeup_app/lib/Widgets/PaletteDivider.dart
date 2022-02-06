import 'package:flutter/material.dart' hide FlatButton, OutlineButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorProcessingTF.dart';
import '../ColorMath/ColorObjects.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../types.dart';
import 'ImagePicker.dart';
import 'BorderBox.dart';
import '../Data/Swatch.dart';
import 'FlatButton.dart';
import 'OutlineButton.dart';

class PaletteDivider extends StatefulWidget {
  final void Function(List<Swatch>)? onEnter;
  final void Function(List<Uint8List>)? onEnterImgs;

  final File? initialImg;

  PaletteDivider({ Key? key, this.onEnter, this.onEnterImgs, this.initialImg }) : super(key: key);

  @override
  PaletteDividerState createState() => PaletteDividerState();
}

class PaletteDividerState extends State<PaletteDivider> {
  static const double minBorders = 0;
  static const double orgBorders = 0;

  static const double minPadding = 10;
  static const double orgPadding = 25;
  static const double maxPadding = 10;

  static const double minSize = 10;

  GlobalKey _imgKey = GlobalKey();
  GlobalKey _borderKey = GlobalKey();
  List<GlobalKey> _borderKeys = [];

  Size _imgSize = Size.zero;
  late Future<Size> _actualImg;

  static int _numCols = 1;
  static int _numRows = 1;

  late TextEditingController _colsController;
  late TextEditingController _rowsController;

  static List<double> _borders = [orgBorders, orgBorders, orgBorders, orgBorders];
  static List<double> _padding = [orgPadding, orgPadding];

  int _draggingCorner = 0;

  List<Swatch> _swatches = [];

  @override
  void initState() {
    super.initState();
    _actualImg = ImagePicker.getActualImgSize(ImagePicker.img);
    _colsController = TextEditingController(text: _numCols.toString());
    _rowsController = TextEditingController(text: _numRows.toString());
  }

  static void reset({ bool includeImg = true }) {
    if(includeImg) {
      ImagePicker.img = null;
      ImagePicker.error = '';
    }
    _numCols = 1;
    _numRows = 1;
    _borders = [orgBorders, orgBorders, orgBorders, orgBorders];
    _padding = [orgPadding, orgPadding];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _actualImg,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //determine properties
        bool showImg = false;
        double topPadding = 15;
        Size screenSize = MediaQuery.of(context).size;
        Size maxSize = Size(screenSize.width * 0.9, (screenSize.height * 0.5) - topPadding);
        Size actualImg = Size(100, 100);
        _imgSize = Size(100, 100);
        if(snapshot.connectionState == ConnectionState.done && ImagePicker.img != null) {
        //if(ImagePicker.img != null) {
          showImg = true;
          if(globals.debug) {
            actualImg = Size(355, 355);
          } else {
            actualImg = snapshot.data;
          }
          _imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
        }
        double width = _imgSize.width;
        double height = _imgSize.height;
        //print('$showImg ${snapshot.connectionState} $actualImg $imgSize $borders $numCols');
        double boxWidth = _getBoxWidth();
        double boxHeight = _getBoxHeight();
        //fill borderKeys
        _borderKeys.clear();
        for(int i = 0; i < _numCols; i++) {
          for(int j = 0; j < _numRows; j++) {
            _borderKeys.add(GlobalKey());
          }
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(
              children: <Widget>[
                getPickImgBtn(),
                if(!showImg) Container(
                  alignment: const Alignment(0, -0.77),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    getString('paletteDivider_warning'),
                    style: theme.primaryTextSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.73),
                  child: getAnimatedOpacity(
                    showImg,
                    child: Row(
                      children: <Widget>[
                        getTextField(screenSize, getString('paletteDivider_columns'), _colsController, (String val) { setState(() { _setDimensions(_toInt(val), _numRows); }); }),
                        getTextField(screenSize, getString('paletteDivider_rows'), _rowsController, (String val) { setState(() { _setDimensions(_numCols,  _toInt(val)); }); })
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

  Widget getAnimatedOpacity(bool showImg, { required Widget child }) {
    return AnimatedOpacity(
      opacity: (showImg ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget getTextField(Size? screenSize, String label, TextEditingController controller, OnStringAction onStringAction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: (screenSize == null ? 175 : screenSize.width / 2),
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        style: theme.primaryTextPrimary,
        controller: controller,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorColor: theme.accentColor,
        decoration: InputDecoration(
          fillColor: theme.primaryColorLight,
          labelText: label,
          labelStyle: theme.primaryTextPrimary,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.primaryColorDarkest,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
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
    OnVoidAction onPressed = () {
      ImagePicker.error = '';
      ImagePicker.open(context).then(
        (val) {
          setState(() {
            if(ImagePicker.prevImg != ImagePicker.img) {
              reset(includeImg: false);
              this._actualImg = ImagePicker.getActualImgSize(ImagePicker.img);
              this._colsController.value = TextEditingValue(
                text: _numCols.toString(),
                selection: this._colsController.selection,
              );
              this._rowsController.value = TextEditingValue(
                text: _numRows.toString(),
                selection: this._rowsController.selection,
              );
            }
          });
        }
      );
    };
    Widget child = Text(
      getString('paletteDivider_add'),
      style: (ImagePicker.img == null ? theme.accentTextBold : TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily)),
    );
    return Align(
      alignment: const Alignment(0, -1),
      child: ImagePicker.img == null ? FlatButton(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: onPressed,
        child: child,
      ) : OutlineButton(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        bgColor: theme.bgColor,
        outlineColor: theme.primaryColorDark,
        outlineWidth: 2.0,
        onPressed: onPressed,
        child: child,
      ),
    );
  }

  Widget getEnterBtn(bool showImg) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: getAnimatedOpacity(
        showImg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 23),
          child: FlatButton(
            bgColor: theme.primaryColorDark,
            onPressed: save,
            child: Text(
              getString('save'),
              style: theme.primaryTextBold,
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
        alignment: const Alignment(0, 0.4),
        child: Image.asset(
          'imgs/test0.jpg',
          key: _imgKey,
          width: _imgSize.width,
          height: _imgSize.height,
        ),
      );
    }
    //release mode uses actual image picked
    return Align(
      alignment: const Alignment(0, 0.4),
      child: Image.file(
        (ImagePicker.img == null ? File('imgs/finish_matte.png') : ImagePicker.img!),
        key: _imgKey,
        width: _imgSize.width,
        height: _imgSize.height,
      ),
    );
  }

  Widget getOuterBorder(double width, double height) {
    return Align(
      alignment: const Alignment(0, 0.4),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (DragUpdateDetails drag) { onBordersChange(drag, _borderKey.currentWidget as BorderBox); },
        child: BorderBox(
          key: _borderKey,
          width: width,
          height: height,
          borderWidth: 3,
          borderColor: Colors.black,
          padding: EdgeInsets.fromLTRB(_borders[0], _borders[1], _borders[2], _borders[3]),
        ),
      ),
    );
  }

  Widget getInnerBorders(double width, double height, double boxWidth, double boxHeight) {
    return Align(
      alignment: const Alignment(0, 0.4),
      child: Stack(
        children: [
          for(int i = 0; i < _numCols; i++) for(int j = 0; j < _numRows; j++) GestureDetector(
            onPanUpdate: (DragUpdateDetails drag) { onPaddingChange(drag, _borderKeys[j * _numCols + i].currentWidget as BorderBox); },
            child: BorderBox(
              key: _borderKeys[j * _numCols + i],
              width: boxWidth,
              height: boxHeight,
              borderWidth: 2,
              borderColor: Colors.black,
              offset: EdgeInsets.fromLTRB(
                (i * boxWidth) + _borders[0],
                (j * boxHeight) + _borders[1],
                width - ((i + 1) * boxWidth) - _borders[0],
                height - ((j + 1) * boxHeight) - _borders[1],
              ),
              padding: EdgeInsets.fromLTRB(_padding[0], _padding[1], _padding[0], _padding[1]),
            ),
          ),
        ],
      ),
    );
  }

  double _getBoxWidth() {
    return (_imgSize.width - (_borders[0] + _borders[2])) / _numCols;
  }

  double _getBoxHeight() {
    return (_imgSize.height - (_borders[1] + _borders[3])) / _numRows;
  }

  void _setDimensions(int cols, int rows) {
    _numCols = cols;
    _numRows = rows;
    double boxWidth = _getBoxWidth();
    double boxHeight = _getBoxHeight();
    double innerWidth = boxWidth - (_padding[0] * 2);
    if(innerWidth < minSize) {
      double diff = minSize - innerWidth;
      _padding[0] -= diff / 2;
      _padding[0] = max(_padding[0], minPadding);
    }
    double innerHeight = boxHeight - (_padding[1] * 2);
    if(innerHeight < minSize) {
      double diff = minSize - innerHeight;
      _padding[1] -= diff / 2;
      _padding[1] = max(_padding[1], minPadding);
    }
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
        _borders[2] -= drag.delta.dx;
        _borders[3] -= drag.delta.dy;
        break;
      case 1:
        _borders[2] -= drag.delta.dx;
        _borders[1] += drag.delta.dy;
        break;
      case 2:
        _borders[0] += drag.delta.dx;
        _borders[3] -= drag.delta.dy;
        break;
      case 3:
        _borders[0] += drag.delta.dx;
        _borders[1] += drag.delta.dy;
        break;
    }
    _update();
  }

  void onPaddingChange(DragUpdateDetails drag, BorderBox border) {
    _getDraggingCorner(drag, border);
    switch(_draggingCorner) {
      case 0:
        _padding[0] -= drag.delta.dx;
        _padding[1] -= drag.delta.dy;
        break;
      case 1:
        _padding[0] -= drag.delta.dx;
        _padding[1] += drag.delta.dy;
        break;
      case 2:
        _padding[0] += drag.delta.dx;
        _padding[1] -= drag.delta.dy;
        break;
      case 3:
        _padding[0] += drag.delta.dx;
        _padding[1] += drag.delta.dy;
        break;
    }
    _update();
  }

  void _update() {
    _updateBorders();
    _updatePadding();
  }

  void _updateBorders() {
    _borders[0] = max(_borders[0], minBorders);
    _borders[1] = max(_borders[1], minBorders);
    _borders[2] = max(_borders[2], minBorders);
    _borders[3] = max(_borders[3], minBorders);
    BorderBox borderBox = _borderKey.currentWidget as BorderBox;
    borderBox.padding = EdgeInsets.fromLTRB(_borders[0], _borders[1], _borders[2], _borders[3]);
    (_borderKey.currentState as BorderBoxState).update();
  }

  void _updatePadding() {
    double width = _imgSize.width;
    double height = _imgSize.height;
    double boxWidth = _getBoxWidth();
    double boxHeight = _getBoxHeight();
    double maxX = (boxWidth - maxPadding) / 2;
    double maxY = (boxHeight - maxPadding) / 2;
    _padding = [max(min(_padding[0], maxX), minPadding), max(min(_padding[1], maxY), minPadding)];
    for(int i = 0; i < _numCols; i++) {
      for(int j = 0; j < _numRows; j++) {
        BorderBox subBorderBox = (_borderKeys[j * _numCols + i].currentWidget as BorderBox);
        subBorderBox.width = boxWidth;
        subBorderBox.height = boxHeight;
        subBorderBox.offset = EdgeInsets.fromLTRB(
          (i * boxWidth) + _borders[0],
          (j * boxHeight) + _borders[1],
          width - ((i + 1) * boxWidth) - _borders[0],
          height - ((j + 1) * boxHeight) - _borders[1],
        );
        subBorderBox.padding = EdgeInsets.fromLTRB(_padding[0], _padding[1], _padding[0], _padding[1]);
        (_borderKeys[j * _numCols + i].currentState as BorderBoxState).update();
      }
    }
  }

  void save() async {
    if(widget.onEnter != null) {
      globalWidgets.openLoadingDialog(context);
      await getNewSwatches();
      Navigator.pop(context);
      widget.onEnter!(_swatches);
    } else if(widget.onEnterImgs != null) {
      widget.onEnterImgs!(await divideImgs());
    }
  }

  Future<List<Uint8List>> divideImgs() async {
    List<Uint8List> imgs = [];
    image.Image? img;
    Size actualImg;
    if(globals.debug) {
      img = await loadImg('imgs/test0.jpg');
      actualImg = Size(355, 355);
    } else {
      img = await loadImg(ImagePicker.img!.path);
      actualImg = await ImagePicker.getActualImgSize(ImagePicker.img);
    }
    if(img != null) {
      double imgScale = _imgSize.width / actualImg.width;
      double boxWidth = _getBoxWidth();
      double scaledBoxWidth = boxWidth / imgScale;
      double boxHeight = _getBoxHeight();
      double scaledBoxHeight = boxHeight / imgScale;
      List<double> scaledBorders = [_borders[0] / imgScale, _borders[1] / imgScale, _borders[2] / imgScale, _borders[3] / imgScale];
      List<double> scaledPadding = [_padding[0] / imgScale, _padding[1] / imgScale];
      for(int j = 0; j < _numRows; j++) {
        //for(int i = _numCols - 1; i >= 0; i--) {
        //I'm constantly changing between the two, they sometimes look wrong, is not consistent? Try printing cropped.exif.orientation
        for(int i = 0; i < _numCols; i++) {
          //get dimensions
          int x = (scaledBorders[0] + (scaledBoxWidth * i) + scaledPadding[0]).floor();
          int y = (scaledBorders[1] + (scaledBoxHeight * j) + scaledPadding[1]).floor();
          int w = (scaledBoxWidth - (scaledPadding[0] * 2)).floor();
          int h = (scaledBoxHeight - (scaledPadding[1] * 2)).floor();
          //crop image
          image.Image? cropped;
          if(img.width == actualImg.width) {
            //correct orientation
            cropped = cropWithBorder(img, x, y, w, h);
          } else {
            //rotated orientation
            cropped = cropWithBorder(img, y, x, h, w);
          }
          if(cropped != null) {
            imgs.add(Uint8List.fromList(image.encodeJpg(cropped)));
          }
        }
      }
    }
    return imgs;
  }

  Future<void> getNewSwatches() async {
    await getModel();
    _swatches = [];
    image.Image? img;
    Size actualImg;
    if(globals.debug) {
      img = await loadImg('imgs/test0.jpg');
      actualImg = Size(355, 355);
    } else {
      img = await loadImg(ImagePicker.img!.path);
      actualImg = await ImagePicker.getActualImgSize(ImagePicker.img);
    }
    if(img != null) {
      double imgScale = _imgSize.width / actualImg.width;
      double boxWidth = _getBoxWidth();
      double scaledBoxWidth = boxWidth / imgScale;
      double boxHeight = _getBoxHeight();
      double scaledBoxHeight = boxHeight / imgScale;
      List<double> scaledBorders = [_borders[0] / imgScale, _borders[1] / imgScale, _borders[2] / imgScale, _borders[3] / imgScale];
      List<double> scaledPadding = [_padding[0] / imgScale, _padding[1] / imgScale];
      for(int j = 0; j < _numRows; j++) {
       //for(int i = _numCols - 1; i >= 0; i--) {
        //I'm constantly changing between the two, they sometimes look wrong, is not consistent? Try printing cropped.exif.orientation
        for(int i = 0; i < _numCols; i++) {
          //get dimensions
          int x = (scaledBorders[0] + (scaledBoxWidth * i) + scaledPadding[0]).floor();
          int y = (scaledBorders[1] + (scaledBoxHeight * j) + scaledPadding[1]).floor();
          int w = (scaledBoxWidth - (scaledPadding[0] * 2)).floor();
          int h = (scaledBoxHeight - (scaledPadding[1] * 2)).floor();
          //crop image
          image.Image? cropped;
          if(img.width == actualImg.width) {
            //correct orientation
            cropped = cropWithBorder(img, x, y, w, h);
          } else {
            //rotated orientation
            cropped = cropWithBorder(img, y, x, h, w);
          }
          if(cropped == null) {
            return;
          }
          //get color
          RGBColor color = avgColor(cropped);
          //get finish
          String finish = await getFinish(cropped);
          //get shade name
          List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
          String shade = '';
          switch(globals.autoShadeNameMode) {
            case globals.AutoShadeNameMode.ColLetters:
              shade = '${j + 1}${letters[i % letters.length]}';
              break;
            case globals.AutoShadeNameMode.RowLetters:
              shade = '${letters[j % letters.length]}${i + 1}';
              break;
            default:
              shade = '';
              break;
          }
          //create swatch
          _swatches.add(Swatch(color: color, finish: finish, brand: '', palette: '', shade: shade, rating: 5, tags: [], imgIds: []));
          //print('${_swatches.last.color.getValues()} $finish');
        }
      }
    }
  }

  image.Image? cropWithBorder(image.Image src, int x, int y, int w, int h) {
    //crops with a 10% border
    x += (w * 0.1).toInt();
    w = (w * 0.8).toInt();
    y += (h * 0.1).toInt();
    h = (h * 0.8).toInt();
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
