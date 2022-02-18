import 'package:flutter/material.dart' hide HSVColor, FlatButton;
import 'dart:typed_data';
import '../../IO/localizationIO.dart';
import '../../globalWidgets.dart' as globalWidgets;
import '../../globals.dart' as globals;
import '../../theme.dart' as theme;
import '../../types.dart';
import '../ImagePicker.dart';
import '../PaletteDivider.dart';
import '../TagsField.dart';
import '../FlatButton.dart';
import 'SwatchImagePopup.dart';

class SwatchImageMultiplePopup extends StatefulWidget {
  final int? swatchId;
  final List<String> otherImgIds;
  final OnStringListAction? onImgIdsAdded;
  final OnSwatchImageListAction? onImgsAdded;

  SwatchImageMultiplePopup({ this.swatchId, required this.otherImgIds, this.onImgIdsAdded, this.onImgsAdded });

  @override
  State<StatefulWidget> createState() => SwatchImageMultiplePopupState();
}

class SwatchImageMultiplePopupState extends State<SwatchImageMultiplePopup> with SwatchImagePopupState {
  @override
  Widget build(BuildContext context) {
    if(!hasInit) {
      ImagePicker.img = null;
      hasInit = true;
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

  @override
  Future<void> openImgPicker(BuildContext context) {
    PaletteDividerState.reset(includeImg: false);
    return super.openImgPicker(context);
  }

  @override
  Future<void> openAfterImgPicker(BuildContext context) async {
    return openImgDivider(context);
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

  @override
  Future<void> openImgDisplay(BuildContext context, List<Uint8List>? imgs) async {
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
                                crossAxisCount: imgs!.length < 4 ? imgs.length : 4,
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
                                imgs,
                                widget.swatchId,
                                widget.otherImgIds,
                                widget.onImgIdsAdded,
                                widget.onImgsAdded,
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
