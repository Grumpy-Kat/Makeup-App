import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:image_picker/image_picker.dart' as Image_Picker;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class ImagePicker {
  static File prevImg;
  static File img;
  static bool isOpen = false;

  static Future<void> open(BuildContext context) {
    isOpen = true;
    return globalWidgets.openDialog(
      context,
      (BuildContext context) {
        return globalWidgets.getAlertDialog(
          context,
          content: Container(
            height: 150,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Choose photo from:', style: theme.primaryTextBold),
                  ),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.image, color: theme.iconTextColor),
                  label: Text('Open Gallery', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
                  onPressed: () {
                    _openGallery(context);
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.camera, color: theme.iconTextColor),
                  label: Text('Open Camera', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
                  onPressed: () {
                    _openCamera(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _openGallery(BuildContext context) async {
    File newImg = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.gallery);
    prevImg = img;
    if(newImg != null) {
      img = newImg;
      if(isOpen) {
        isOpen = false;
        //doesn't use navigation because is popping an Dialog
        Navigator.pop(context);
      }
    }
  }

  static void _openCamera(BuildContext context) async {
    File newImg = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.camera);
    prevImg = img;
    if(newImg != null) {
      img = newImg;
      if(isOpen) {
        isOpen = false;
        //doesn't use navigation because is popping an Dialog
        Navigator.pop(context);
      }
    }
  }

  static Future<Size> getActualImgSize(File f) async {
    if(f == null) {
      print('getActualImgSize: Img is null');
      return Size(0, 0);
    }
    Image decoded = await decodeImageFromList(await f.readAsBytes());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }

  static Size getScaledImgSize(Size maxSize, Size actualImg) {
    if(maxSize == null || actualImg == null) {
      return Size(0, 0);
    }
    double multiplier = maxSize.width / actualImg.width;
    if(actualImg.width == 0) {
      multiplier = 0;
    }
    Size imgSize = actualImg * multiplier;
    if(imgSize.height > maxSize.height) {
      multiplier = maxSize.height / actualImg.height;
      if(actualImg.height == 0) {
        multiplier = 0;
      }
      imgSize = actualImg * multiplier;
    }
    return imgSize;
  }
}
