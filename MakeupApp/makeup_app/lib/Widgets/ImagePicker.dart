import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart' as Image_Picker;
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;

class ImagePicker {
  static BuildContext _context;
  static File prevImg;
  static File img;
  static String error = '';
  static bool isOpen = false;

  static Future<void> open(BuildContext context) {
    isOpen = true;
    _context = context;
    return globalWidgets.openDialog(
      context,
      (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return globalWidgets.getAlertDialog(
              context,
              content: Container(
                height: (error == '' ? 150 : 200),
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
                        _openGallery(context, setState);
                      },
                    ),
                    FlatButton.icon(
                      icon: Icon(Icons.camera, color: theme.iconTextColor),
                      label: Text('Open Camera', textAlign: TextAlign.left, style: theme.primaryTextPrimary),
                      onPressed: () {
                        _openCamera(context, setState);
                      },
                    ),
                    if(error != '') Text(error, style: theme.errorTextTertiary),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void _openGallery(BuildContext context, void Function(void Function()) setState) async {
    PermissionStatus status;
    if(Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    if(status.isGranted) {
      if(error != '') {
        setState(() { error = ''; });
      }
      try {
        File newImg = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.gallery);
        prevImg = img;
        if(newImg != null) {
          img = newImg;
          if(isOpen) {
            isOpen = false;
            //doesn't use navigation because is popping an Dialog
            Navigator.pop(_context);
          }
        }
      } catch(e) {
        print('_openGallery $e');
      }
    } else {
      //reopen and reload
      if(isOpen) {
        setState(() { error = 'Gallery permissions are denied. Please open your phone\'s settings to allow ${globals.appName} to access your gallery.'; });
      }
    }
  }

  static void _openCamera(BuildContext context, void Function(void Function()) setState) async {
    PermissionStatus status = await Permission.photos.request();
    if(status.isGranted) {
      if(error != '') {
        setState(() { error = ''; });
      }
      try {
        File newImg = await Image_Picker.ImagePicker.pickImage(source: Image_Picker.ImageSource.camera);
        prevImg = img;
        if(newImg != null) {
          img = newImg;
          if(isOpen) {
            isOpen = false;
            //doesn't use navigation because is popping an Dialog
            Navigator.pop(_context);
          }
        }
      } catch(e) {
        print('_openCamera $e');
      }
    } else {
      //reopen and reload
      if(isOpen) {
        setState(() { error = 'Camera permissions are denied. Please open your phone\'s settings to allow ${globals.appName} to access your camera.'; });
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
