import 'package:flutter/material.dart' hide HSVColor, FlatButton;
import 'dart:typed_data';
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../types.dart';
import 'ImagePicker.dart';
import 'SwatchImage.dart';
import 'PaletteDivider.dart';
import 'FlatButton.dart';

class SwatchImageMultiplePopup extends StatefulWidget {
  final int? swatchId;
  final List<String> otherImgIds;
  final OnStringListAction? onImgIdsAdded;
  final OnSwatchImageListAction? onImgsAdded;

  SwatchImageMultiplePopup({ this.swatchId, required this.otherImgIds, this.onImgIdsAdded, this.onImgsAdded });

  @override
  State<StatefulWidget> createState() => SwatchImageMultiplePopupState();
}

class SwatchImageMultiplePopupState extends State<SwatchImageMultiplePopup> {
  List<String> labels = [];

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
        color: theme.primaryColorDarkest,
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
    PaletteDividerState.reset(includeImg: false);
    return ImagePicker.open(context).then(
      (val) {
        if(ImagePicker.img != null) {
          openImgDivider(context);
        }
      },
    );
  }

  Future<void> openImgDivider(BuildContext context) async {
    return globalWidgets.openDialog(
      context,
      (BuildContext innerContext) {
        return StatefulBuilder(
          builder: (innerContext, setState) {
            return Padding(
              padding: MediaQuery.of(innerContext).viewInsets.bottom != 0 ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.1, horizontal: 0),
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                shape: const RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                ),
                child: PaletteDivider(
                  initialImg: ImagePicker.img,
                  onEnterImgs: (List<Uint8List> imgs) {
                    Navigator.pop(innerContext);
                    openImgDisplay(innerContext, imgs);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> openImgDisplay(BuildContext context, List<Uint8List> imgs) async {
    double padding = (MediaQuery.of(context).size.height * 0.5) - 350;
    if(padding < 0) {
      padding = 0;
    }
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
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                crossAxisCount: imgs.length < 4 ? imgs.length : 4,
                              ),
                              itemCount: imgs.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Image.memory(
                                  imgs[i],
                                );
                              },
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
                              globalWidgets.openLoadingDialog(context);
                              List<String>? imgIds;
                              if(widget.swatchId != null) {
                                imgIds = [];
                                for(int i = 0; i < imgs.length; i++) {
                                  imgIds.add(await allSwatchesStorageIO.addImgBytes(bytes: imgs[i], otherImgIds: widget.otherImgIds, swatchId: widget.swatchId!, labels: labels));
                                }
                              }
                              _hasInit = false;
                              Navigator.pop(context);
                              Navigator.pop(context);
                              if(imgIds != null && widget.onImgIdsAdded != null) {
                                widget.onImgIdsAdded!(imgIds);
                              }
                              if(widget.onImgsAdded != null) {
                                if(imgIds != null) {
                                  List<SwatchImage> savedImgs = [];
                                  for(int i = 0; i < imgIds.length; i++) {
                                    savedImgs.add((await allSwatchesStorageIO.getImg(swatchId: widget.swatchId!, imgId: imgIds[i]))!);
                                  }
                                  widget.onImgsAdded!(savedImgs);
                                } else {
                                  List<SwatchImage> newImgs = [];
                                  for(int i = 0; i < imgs.length; i++) {
                                    newImgs.add(SwatchImage(id: '', labels: labels, bytes: imgs[i]));
                                  }
                                  widget.onImgsAdded!(newImgs);
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
