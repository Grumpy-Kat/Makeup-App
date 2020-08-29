import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:image_picker/image_picker.dart' as Image_Picker;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class ImagePicker {
  static File img;

  static Future<void> open(BuildContext context) {
    return globalWidgets.openDialog(
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
              icon: Icon(Icons.image),
              label: Text('Open Gallery', textAlign: TextAlign.left, style: theme.primaryText),
              onPressed: () {
                _openGallery(context);
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Open Camera', textAlign: TextAlign.left, style: theme.primaryText),
              onPressed: () {
                _openCamera(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _openGallery(BuildContext context) async {
    File before = img;
    img = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.gallery);
    if(img != null && before != img) {
      //doesn't use navigation because is popping an Dialog
      Navigator.pop(context);
    }
  }

  static void _openCamera(BuildContext context) async {
    File before = img;
    img = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.camera);
    if(img != null && before != img) {
      //doesn't use navigation because is popping an Dialog
      Navigator.pop(context);
    }
  }

  static Future<Size> getActualImgSize(File f) async {
    if(f == null) {
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
    Size imgSize = actualImg * multiplier;
    if(imgSize.height > maxSize.height) {
      multiplier = maxSize.height / actualImg.height;
      imgSize = actualImg * multiplier;
    }
    return imgSize;
  }
}
