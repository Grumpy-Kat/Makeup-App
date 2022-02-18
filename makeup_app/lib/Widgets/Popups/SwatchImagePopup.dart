import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../../../Data/SwatchImage.dart';
import '../../../types.dart';
import '../../../globalWidgets.dart' as globalWidgets;
import '../ImagePicker.dart';

mixin SwatchImagePopupState {
  List<String> labels = [];
  bool isImgDisplayOpened = false;

  // ignore: unused_field
  bool hasInit = false;

  Future<void> openImgPicker(BuildContext context) {
    ImagePicker.error = '';
    return ImagePicker.open(context).then(
      (val) {
        if(ImagePicker.img != null && !isImgDisplayOpened) {
          openAfterImgPicker(context);
        }
      },
    );
  }

  Future<void> openAfterImgPicker(BuildContext context) async {
    return openImgDisplay(context, null);
  }

  Future<void> openImgDisplay(BuildContext context, List<Uint8List>? imgs) async { }

  Future<void> addImgs(BuildContext context, List<Uint8List> imgs, int? swatchId, List<String> otherImgIds, OnStringListAction? onImgIdsAdded, OnSwatchImageListAction? onImgsAdded) async {
    globalWidgets.openLoadingDialog(context);

    // Save images
    List<String>? imgIds;
    if(swatchId != null) {
      imgIds = [];
      for(int i = 0; i < imgs.length; i++) {
        imgIds.add(await allSwatchesStorageIO.addImgBytes(bytes: imgs[i], otherImgIds: otherImgIds, swatchId: swatchId, labels: labels));
      }
    }

    // Reset state and allow user to return, while finishing operations in background
    hasInit = false;
    Navigator.pop(context);
    Navigator.pop(context);

    // Call change functions
    if(imgIds != null && onImgIdsAdded != null) {
      onImgIdsAdded(imgIds);
    }

    // Call change functions
    if(onImgsAdded != null) {
      List<SwatchImage> addedImgs = [];

      if(imgIds != null) {
        for(int i = 0; i < imgIds.length; i++) {
          addedImgs.add((await allSwatchesStorageIO.getImg(swatchId: swatchId!, imgId: imgIds[i]))!);
        }
      } else {
        for(int i = 0; i < imgs.length; i++) {
          addedImgs.add(SwatchImage(id: '', labels: labels, bytes: imgs[i]));
        }
      }

      onImgsAdded(addedImgs);
    }
  }
}