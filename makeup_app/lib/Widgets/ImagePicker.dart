import 'package:flutter/material.dart' hide Image;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart' as Image_Picker;
import 'dart:io';
import 'dart:ui';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class ImagePicker {
  static late BuildContext _context;
  static final picker = Image_Picker.ImagePicker();
  static File? prevImg;
  static File? img;
  static String error = '';
  static bool isOpen = false;

  static Future<void> open(BuildContext context) {
    prevImg = img;
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
                        child: Text(getString('imagePicker_chooseMode'), style: theme.primaryTextBold),
                      ),
                    ),
                    FlatButton.icon(
                      icon: Icon(Icons.image, color: theme.iconTextColor),
                      label: Text(getString('imagePicker_gallery'), textAlign: TextAlign.left, style: theme.primaryTextPrimary),
                      onPressed: () {
                        openGallery(context, setState);
                      },
                    ),
                    FlatButton.icon(
                      icon: Icon(Icons.camera, color: theme.iconTextColor),
                      label: Text(getString('imagePicker_camera'), textAlign: TextAlign.left, style: theme.primaryTextPrimary),
                      onPressed: () {
                        openCamera(context, setState);
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

  static Future<void> openGallery(BuildContext context, void Function(void Function()) setState) async {
    PermissionStatus status;
    if(Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    if(status.isGranted) {
      if(error != '') {
        error = '';
        setState(() { });
      }
      try {
        Image_Picker.XFile? file = await picker.pickImage(source: Image_Picker.ImageSource.gallery);
        if(file != null) {
          File newImg = File(file.path);
          prevImg = img;
          if(await newImg.exists()) {
            img = newImg;
            if(isOpen) {
              isOpen = false;
              //doesn't use navigation because is popping an Dialog
              Navigator.pop(_context);
            }
          }
        }
      } catch(e) {
        print('_openGallery $e');
      }
    } else {
      //reopen and reload
      error = getString('imagePicker_galleryError');
      if(isOpen) {
        setState(() { });
      }
    }
  }

  static Future<void> openCamera(BuildContext context, void Function(void Function()) setState) async {
    PermissionStatus status = await Permission.camera.request();
    if(status.isGranted) {
      if(error != '') {
        error = '';
        setState(() { });
      }
      try {
        Image_Picker.XFile? file = await picker.pickImage(source: Image_Picker.ImageSource.camera);
        if(file != null) {
          File newImg = File(file.path);
          prevImg = img;
          if(await newImg.exists()) {
            img = newImg;
            if(isOpen) {
              isOpen = false;
              //doesn't use navigation because is popping an Dialog
              Navigator.pop(_context);
            }
          }
        }
      } catch(e) {
        print('_openCamera $e');
      }
    } else {
      //reopen and reload
      error = getString('imagePicker_cameraError');
      if(isOpen) {
        setState(() { });
      }
    }
  }

  static Future<Size> getActualImgSize(File? f) async {
    if(f == null) {
      print('getActualImgSize: Img is null');
      return Size(0, 0);
    }
    Image decoded = await decodeImageFromList(await f.readAsBytes());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }

  static Size getScaledImgSize(Size? maxSize, Size? actualImg) {
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
