import 'package:flutter/material.dart' hide FlatButton, OutlineButton;
import '../IO/allSwatchesStorageIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../types.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../Data/Swatch.dart';
import '../Data/SwatchImage.dart';
import 'SwatchImagePopup.dart';
import 'ImagePicker.dart';
import 'FlatButton.dart';
import 'OutlineButton.dart';
import 'SwatchIcon.dart';

class SwatchImagesDisplay extends StatefulWidget {
  final bool isEditing;
  final List<String> imgIds;
  final Swatch swatch;
  final OnStringListAction onChange;

  SwatchImagesDisplay({ Key? key, required this.isEditing, required this.imgIds, required this.swatch, required this.onChange }) : super(key: key);

  @override
  SwatchImagesDisplayState createState() => SwatchImagesDisplayState();
}

class SwatchImagesDisplayState extends State<SwatchImagesDisplay> {
  late List<String> imgIds;
  Map<String, SwatchImage?> imgs = {};
  int currImgPreviewId = 0;

  String? imgSettingState;

  @override
  void initState() {
    super.initState();
    imgIds = widget.imgIds;
  }

  @override
  Widget build(BuildContext context) {
    Widget imgPreview;
    if(currImgPreviewId == 0) {
      imgPreview = SwatchIcon.swatch(widget.swatch, showInfoBox: false, overrideOnDoubleTap: true, onDoubleTap: (int id) {});
    } else {
      SwatchImage img = imgs[imgIds[currImgPreviewId - 1]]!;
      imgPreview = FlatButton(
        padding: const EdgeInsets.all(0),
        child: Image.memory(
          img.bytes,
          height: 140,
        ),
        onPressed: () {
          openEditImg(
            img,
            () {
              imgs.remove(imgIds[currImgPreviewId - 1]);
              imgIds.removeAt(currImgPreviewId - 1);
              widget.onChange(imgIds);
              currImgPreviewId = 0;
              setState(() {});
            }
          );
        },
      );
    }

    List<Widget> imgWidgets = getImgs();
    imgWidgets.insert(0, SwatchIcon.swatch(widget.swatch, showInfoBox: false, overrideOnTap: true, onTap: (int id) { setState(() { currImgPreviewId = 0; }); }, overrideOnDoubleTap: true, onDoubleTap: (int id) {}));
    if(widget.isEditing) {
      imgWidgets.add(
        SwatchImagePopup(
          swatchId: widget.swatch.id,
          otherImgIds: imgIds,
          onImgIdAdded: (String id) {
            imgIds.add(id);
            widget.onChange(imgIds);
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 125,
          child: imgPreview,
        ),
        if(imgWidgets.length > 1) Container(
          height: 50,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (BuildContext context, int i) {
              return const SizedBox(
                width: 15,
              );
            },
            itemCount: imgWidgets.length,
            itemBuilder: (BuildContext context, int i) {
              return imgWidgets[i];
            },
          ),
        ),
      ],
    );
  }

  List<Widget> getImgs() {
    List<Widget> imgWidgets = [];
    for(int i = 0; i < imgIds.length; i++) {
      if(imgIds[i] == '') {
        continue;
      }
      if(!imgs.containsKey(imgIds[i])) {
        imgWidgets.add(
          Container(
            width: 50,
            height: 50,
            child: const CircularProgressIndicator(),
          ),
        );
        imgSettingState = imgIds[i];
        IO.getImg(swatchId: widget.swatch.id, imgId: imgIds[i]).then(
          (SwatchImage? img) {
            if(img != null && img.bytes.length > 0) {
              imgs[imgIds[i]] = img;
              //only setState if last processing img, in order to avoid settingState multiple times
              if(imgSettingState == imgIds[i]) {
                setState(() {});
              }
            } else {
              imgs[imgIds[i]] = null;
              //only setState if last processing img, in order to avoid settingState multiple times
              if(imgSettingState == imgIds[i]) {
                setState(() {});
              }
            }
          }
        );
      } else {
        if(imgs[imgIds[i]] != null) {
          int id = i + 1;
          imgWidgets.add(
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
              ),
              child: GestureDetector(
                child: Image.memory(
                  imgs[imgIds[i]]!.bytes,
                  height: 50,
                ),
                onTap: () {
                  setState(() {
                    currImgPreviewId = id;
                  });
                },
              ),
            ),
          );
        }
      }
    }
    return imgWidgets;
  }

  Future<void> openEditImg(SwatchImage img, OnVoidAction onDelete) {
    double padding = (MediaQuery.of(context).size.height * 0.5) - 350;
    if(padding < 0) {
      padding = 0;
    }
    Size imgSize = ImagePicker.getScaledImgSize(Size(MediaQuery.of(context).size.width - 60, 200), Size(img.width!.toDouble(), img.height!.toDouble()));
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
                            Image.memory(
                              img.bytes,
                              width: imgSize.width,
                              height: imgSize.height,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            getChipField(context, img.labels, (List<String> value) { setState(() { imgs[imgIds[currImgPreviewId - 1]]!.labels = value; img.labels = value; }); }),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 40,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                bgColor: theme.accentColor,
                                onPressed: () async {
                                  globalWidgets.openLoadingDialog(context);
                                  await IO.updateImg(swatchImg: img);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    getString('save'),
                                    style: theme.accentTextBold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: OutlineButton(
                                bgColor: theme.bgColor,
                                outlineColor: theme.primaryColorDark,
                                onPressed: () async {
                                  await globalWidgets.openTwoButtonDialog(
                                    context,
                                    '${getString('swatchImage_deleteWarning')}',
                                    () async {
                                      IO.deleteImg(swatchId: img.swatchId!, imgId: img.id);
                                      onDelete();
                                      Navigator.pop(context);
                                    },
                                    () { },
                                  );
                                },
                                child: Text(
                                  '${getString('swatchImage_delete')}',
                                  style: theme.errorText,
                                ),
                              ),
                            ),
                          ],
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
      if(!widget.isEditing && !labels.contains(options[i])) {
        continue;
      }
      String text = options[i];
      if(text.contains('_')) {
        text = getString(text, defaultValue: text);
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(text, style: theme.primaryTextSecondary),
          selected: labels.contains(options[i]),
          onSelected: (bool selected) {
            if(widget.isEditing) {
              if (selected) {
                labels.add(options[i]);
              } else {
                labels.remove(options[i]);
              }
              onChange(labels);
            }
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }

    if(widget.isEditing) {
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
    }

    if(widgets.length == 0) {
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text('${getString('swatch_none')}', style: theme.primaryTextSecondary),
          selected: false,
          onSelected: (bool selected) { },
        ),
      );
    }

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
