import 'package:flutter/material.dart';
import '../ColorMath/ColorObjects.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import '../types.dart';
import 'InfoBox.dart';

class Swatch {
  int id;
  RGBColor color;
  String colorName;
  String finish;
  String brand;
  String palette;
  String shade = '';

  double weight = 0.0;
  double price = 0.0;

  int rating = 5;
  List<String>? tags = [];

  List<String>? imgIds = [];

  DateTime? openDate = DateTime.now();
  DateTime? expirationDate = DateTime.now();

  Swatch({ required this.color, required this.finish, this.id = -1, this.colorName = '', this.brand = '', this.palette = '', this.shade = '', this.weight = 0.0, this.price = 0.0, this.rating = 5, this.tags, this.imgIds, this.openDate, this.expirationDate });

  int compareTo(Swatch other, List<double> Function(Swatch) comparator) {
    List<double> thisValues = comparator(this);
    List<double> otherValues = comparator(other);
    for(int i = 0; i < thisValues.length; i++) {
      int comp = thisValues[i].compareTo(otherValues[i]);
      if(comp != 0) {
        return comp;
      }
    }
    return 0;
  }

  bool operator ==(other) {
    if(!(other is Swatch)) {
      return false;
    }
    //return id == other.id && color == other.color && finish == other.finish && brand == other.brand && palette == other.palette && shade == other.shade && rating == other.rating && tags == other.tags;
    return id == other.id;
  }
  
  Map<String, dynamic> getMap() {
    return {
      'color': color,
      'colorName': colorName.trim(),
      'finish': finish,
      'brand': brand.trim(),
      'palette': palette.trim(),
      'shade': shade.trim(),
      'weight': weight,
      'price': price,
      'rating': rating,
      'tags': tags,
      'imgIds': imgIds,
      'openDate': openDate,
      'expirationDate': expirationDate,
    };
  }

  @override
  String toString() {
    return '$id $color $finish $brand $palette $shade';
  }

  @override
  int get hashCode => super.hashCode;
}

class SwatchIcon extends StatelessWidget {
  final Swatch? swatch;
  final int id;

  final GlobalKey infoBoxKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();

  final bool addSwatch;
  final bool showInfoBox;
  final bool showMoreBtnInInfoBox;

  final bool showCheck;

  final OnSwatchAction? onDelete;

  final bool overrideOnTap;
  final OnSwatchAction? onTap;

  final bool overrideOnDoubleTap;
  final OnSwatchAction? onDoubleTap;

  //assumes there is no id (probably editing swatch)
  SwatchIcon.swatch(this.swatch, { this.addSwatch = true, this.showInfoBox = true, this.showMoreBtnInInfoBox = true, this.showCheck = false, this.onDelete, this.overrideOnTap = false, this.onTap, this.overrideOnDoubleTap = false, this.onDoubleTap }) : this.id  = (swatch == null ? -1 : swatch.id);

  SwatchIcon.id(this.id, { this.addSwatch = true, this.showInfoBox = true, this.showMoreBtnInInfoBox = true, this.showCheck = false, this.onDelete, this.overrideOnTap = false, this.onTap, this.overrideOnDoubleTap = false, this.onDoubleTap }) : this.swatch = IO.get(id), super(key: GlobalKey(debugLabel: id.toString()));

  @override
  Widget build(BuildContext context) {
    List<double> color;
    String finish;
    if(swatch != null) {
      color = swatch!.color.getValues();
      finish = swatch!.finish.toLowerCase();
    } else {
      color = [0.5, 0.5, 0.5];
      finish = 'finish_matte';
    }
    final Widget swatchImg = Image(
      key: childKey,
      image: AssetImage('imgs/$finish.png'),
      colorBlendMode: BlendMode.modulate,
      color: Color.fromRGBO((color[0] * 255).round(), (color[1] * 255).round(), (color[2] * 255).round(), 1),
    );
    Widget child;
    //will not work if both showCheck == true and onDelete != null, most likely not a concern
    if(showCheck) {
      child = Stack(
        children: <Widget>[
          swatchImg,
          Align(
            alignment: const Alignment(1.15, 1.15),
            child: Container(
              width: 23,
              height: 23,
              child: FloatingActionButton(
                heroTag: 'Check $id',
                backgroundColor: theme.checkTextColor,
                child: Icon(
                  Icons.check,
                  size: 19,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  if(onDelete != null) {
                    onDelete!(id);
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if(onDelete != null) {
      child = Stack(
        children: <Widget>[
          swatchImg,
          Align(
            alignment: const Alignment(1.15, -1.15),
            child: Container(
              width: 23,
              height: 23,
              child: FloatingActionButton(
                heroTag: 'Delete $id',
                backgroundColor: theme.errorTextColor,
                child: Icon(
                  Icons.clear,
                  size: 19,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  if(onDelete != null) {
                    onDelete!(id);
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else {
      child = swatchImg;
    }
    if(showInfoBox) {
      return InfoBox(
        key: infoBoxKey,
        swatch: swatch,
        onTap: overrideOnTap ? () { if(onTap != null) onTap!(id); } : _onTap,
        onDoubleTap: overrideOnDoubleTap ? () { if(onDoubleTap != null) onDoubleTap!(id); } : _onDoubleTap,
        child: child,
        childKey: childKey,
        showMoreBtn: showMoreBtnInInfoBox,
      );
    }
    return GestureDetector(
      onTap: overrideOnTap ? () { if(onTap != null) onTap!(id); } : _onTap,
      onDoubleTap: overrideOnDoubleTap ? () { if(onDoubleTap != null) onDoubleTap!(id); } : _onDoubleTap,
      child: child,
    );
  }

  void _onTap() {
    if(showInfoBox) {
      (infoBoxKey.currentState as InfoBoxState).open();
    }
    if(onTap != null) {
      onTap!(id);
    }
  }

  void _onDoubleTap() {
    if(addSwatch && id != -1 && !globals.currSwatches.currSwatches.contains(this)) {
      globals.currSwatches.add(id);
    }
    if(onDoubleTap != null) {
      onDoubleTap!(id);
    }
  }
}