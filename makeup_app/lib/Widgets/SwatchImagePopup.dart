import 'package:flutter/material.dart' hide HSVColor, FlatButton, OutlineButton;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../types.dart';
import 'ImagePicker.dart';
import 'SwatchImage.dart';
import 'FlatButton.dart';
import 'OutlineButton.dart';

class SwatchImagePopup extends StatefulWidget {
  final int? swatchId;
  final List<String> otherImgIds;
  final OnStringAction? onImgIdAdded;
  final OnSwatchImageAction? onImgAdded;

  SwatchImagePopup({ this.swatchId, required this.otherImgIds, this.onImgIdAdded, this.onImgAdded });

  @override
  State<StatefulWidget> createState() => SwatchImagePopupState();
}

class SwatchImagePopupState extends State<SwatchImagePopup> {
  List<String> labels = [];
  bool _isImgDisplayOpened = false;

  bool _hasInit = false;

  @override
  Widget build(BuildContext context) {
    if(!_hasInit) {
      ImagePicker.img = null;
      _hasInit = true;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: theme.primaryColorDark,
      ),
      child: IconButton(
        constraints: BoxConstraints.tight(const Size.square(50)),
        alignment: Alignment.center,
        icon: Icon(
          Icons.camera_alt,
          size: 30,
          color: theme.bgColor,
        ),
        onPressed: () {
          openImgPicker(context);
        },
      ),
    );
  }

  Future<void> openImgPicker(BuildContext context) {
    ImagePicker.error = '';
    return ImagePicker.open(context).then(
      (val) {
        if(ImagePicker.img != null && !_isImgDisplayOpened) {
          openImgDisplay(context);
        }
      },
    );
  }

  Future<void> openImgDisplay(BuildContext context) async {
    _isImgDisplayOpened = true;
    double padding = (MediaQuery.of(context).size.height * 0.5) - 350;
    if(padding < 0) {
      padding = 0;
    }
    Size imgSize = ImagePicker.getScaledImgSize(Size(MediaQuery.of(context).size.width - 60, 200), await ImagePicker.getActualImgSize(ImagePicker.img));
    return globalWidgets.openDialog(
      context,
      (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 0),
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 700,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 170,
                                height: 40,
                                child: OutlineButton(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                  bgColor: theme.bgColor,
                                  outlineColor: theme.primaryColorDark,
                                  outlineWidth: 2.0,
                                  onPressed: () {
                                    openImgPicker(context).then(
                                      (value) {
                                        if(ImagePicker.img == null) {
                                          Navigator.pop(context);
                                        }
                                        if(ImagePicker.img != ImagePicker.prevImg) {
                                          setState(() {});
                                        }
                                      }
                                    );
                                  },
                                  child: Text(
                                    getString('paletteDivider_add'),
                                    style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Image.file(
                              ImagePicker.img!,
                              width: imgSize.width,
                              height: imgSize.height,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            getChipField(context, labels, (List<String> value) { setState(() { labels = value; }); }),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 170,
                          height: 40,
                          child: FlatButton(
                            bgColor: theme.accentColor,
                            onPressed: () async {
                              String? imgId;
                              if(widget.swatchId != null) {
                                imgId = await allSwatchesStorageIO.addImg(file: ImagePicker.img!, otherImgIds: widget.otherImgIds, swatchId: widget.swatchId!, labels: labels);
                              }
                              _hasInit = false;
                              Navigator.pop(context);
                              if(imgId != null && widget.onImgIdAdded != null) {
                                widget.onImgIdAdded!(imgId);
                              }
                              if(widget.onImgAdded != null) {
                                if(imgId != null) {
                                  widget.onImgAdded!((await allSwatchesStorageIO.getImg(swatchId: widget.swatchId!, imgId: imgId))!);
                                } else {
                                  widget.onImgAdded!(SwatchImage(id: '', labels: labels, bytes: ImagePicker.img!.readAsBytesSync()));
                                }
                              }
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${getString('save')}',
                                style: theme.accentTextBold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      }
    );
  }

  Widget getChipField(BuildContext context, List<String> labels, OnStringListAction onChange) {
    List<Widget> widgets = [];
    List<String> options = globals.swatchImgLabels;
    for(int i = 0; i < options.length; i++) {
      if(options[i] == '') {
        continue;
      }
      String text = options[i];
      if(text.contains('_')) {
        text = getString(text);
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(text, style: theme.primaryTextSecondary),
          selected: labels.contains(options[i]),
          onSelected: (bool selected) {
            if(selected) {
              labels.add(options[i]);
            } else {
              labels.remove(options[i]);
            }
            onChange(labels);
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }

    widgets.add(
      ActionChip(
        label: Icon(
          Icons.add,
          size: 15,
          color: theme.iconTextColor,
        ),
        onPressed: () {
          globalWidgets.openTextDialog(
            context,
            getString('swatch_tags_popupInstructions'),
            getString('swatch_tags_popupError'),
            getString('swatch_tags_popupBtn'),
            (String value) {
              options.add(value);
              globals.swatchImgLabels = options;
              labels.add(value);
              onChange(labels);
            },
          );
        },
      ),
    );

    return Column(
      children: <Widget> [
        Container(
          height: 55,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 3),
          child: Text(
            '${getString('swatchImage_labels')}: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Wrap(
            children: widgets,
          ),
        ),
      ],
    );
  }
}
