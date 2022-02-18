import 'package:flutter/material.dart' hide HSVColor, FlatButton, OutlineButton;
import 'dart:typed_data';
import '../../Data/SwatchImage.dart';
import '../../IO/localizationIO.dart';
import '../../globalWidgets.dart' as globalWidgets;
import '../../globals.dart' as globals;
import '../../theme.dart' as theme;
import '../../types.dart';
import '../ImagePicker.dart';
import '../FlatButton.dart';
import '../TagsField.dart';
import '../OutlineButton.dart';
import 'SwatchImagePopup.dart';

class SwatchImageSinglePopup extends StatefulWidget {
  final int? swatchId;
  final List<String> otherImgIds;
  final OnStringAction? onImgIdAdded;
  final OnSwatchImageAction? onImgAdded;

  SwatchImageSinglePopup({ this.swatchId, required this.otherImgIds, this.onImgIdAdded, this.onImgAdded });

  @override
  SwatchImageSinglePopupState createState() => SwatchImageSinglePopupState();
}

class SwatchImageSinglePopupState extends State<SwatchImageSinglePopup> with SwatchImagePopupState {
  @override
  Widget build(BuildContext context) {
    if(!hasInit) {
      ImagePicker.img = null;
      hasInit = true;
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

  @override
  Future<void> openImgDisplay(BuildContext context, List<Uint8List>? imgs) async {
    isImgDisplayOpened = true;

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
                                  outlineColor: theme.primaryColorDarkest,
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

                            TagsField(
                              label: '${getString('swatchImage_labels')}',
                              values: labels,
                              options: globals.swatchImgLabels,
                              onAddOption: (String value) {
                                List<String> labels = globals.swatchImgLabels;
                                labels.add(value);
                                globals.swatchImgLabels = labels;
                              },
                              onChange: (List<String> value) {
                                setState(() {
                                  labels = value;
                                });
                              },
                              labelPadding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 3),
                              chipFieldPadding: const EdgeInsets.only(left: 30, right: 30),
                            ),
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
                              await addImgs(
                                context,
                                [ImagePicker.img!.readAsBytesSync()],
                                widget.swatchId,
                                widget.otherImgIds,
                                widget.onImgIdAdded == null ? null : (List<String> imgIds) { widget.onImgIdAdded!(imgIds[0]); },
                                widget.onImgAdded == null ? null : (List<SwatchImage> imgs) { widget.onImgAdded!(imgs[0]); },
                              );
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
}
