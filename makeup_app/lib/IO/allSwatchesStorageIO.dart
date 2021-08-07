import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as image;
import 'dart:io';
import 'dart:typed_data';
import '../Widgets/SwatchImage.dart';
import '../globals.dart' as globals;

late Reference _folderRef;

//TODO: cache this in the future if worried about performanced

void init() {
  _folderRef = FirebaseStorage.instance.ref('swatchesImgs/${globals.userID}');
}

Future<String> addImg({ required File file, required int swatchId, required List<String> labels, List<String>? otherImgIds, bool shouldCompress = true }) async {
  int imgId = 0;

  try {
    if(otherImgIds != null && otherImgIds.length > 0) {
      print('otherImgIds $otherImgIds');
      String lastId = '';
      int i = otherImgIds.length;
      do {
        i--;
        lastId = otherImgIds[i];
      } while(lastId == '' && i > 0);
      print(lastId);
      imgId = (int.tryParse(lastId) ?? -1) + 1;
    }

    image.Image fileImg = image.decodeImage(file.readAsBytesSync())!;
    if(shouldCompress) {
      fileImg = image.copyResize(fileImg, height: 300);
    }
    Uint8List bytes = Uint8List.fromList(image.encodeJpg(fileImg, quality: shouldCompress ? 85 : 100));

    String labelsCombined = '';
    for(int i = 0; i < labels.length; i++) {
      labelsCombined += '${labels[i]};';
    }
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String> {
        'userId': globals.userID,
        'width': fileImg.width.toString(),
        'height': fileImg.height.toString(),
        'labels': labelsCombined,
      },
    );

    await _folderRef.child('${swatchId}_$imgId.jpg').putData(bytes, metadata);
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }

  return imgId.toString();
}

//most likely don't need to compress because already compressed
Future<void> updateImg({ required SwatchImage swatchImg, bool shouldCompress = false }) async {
  try {
    image.Image fileImg = image.decodeImage(swatchImg.bytes.toList())!;
    if(shouldCompress) {
      fileImg = image.copyResize(fileImg, height: 500);
    }
    Uint8List bytes = Uint8List.fromList(image.encodeJpg(fileImg, quality: shouldCompress ? 85 : 100));

    String labelsCombined = '';
    for(int i = 0; i < swatchImg.labels.length; i++) {
      labelsCombined += '${swatchImg.labels[i]};';
    }
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String> {
        'userId': globals.userID,
        'width': fileImg.width.toString(),
        'height': fileImg.height.toString(),
        'labels': labelsCombined,
      },
    );

    await _folderRef.child('${swatchImg.swatchId}_${swatchImg.id}.jpg').putData(bytes, metadata);
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
}

Future<void> deleteImg({ required int swatchId, required String imgId }) async {
  try {
    await _folderRef.child('${swatchId}_$imgId.jpg').delete();
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
}

Future<SwatchImage?> getImg({ required int swatchId, required String imgId }) async {
  try {
    FullMetadata metadata = await _folderRef.child('${swatchId}_$imgId.jpg').getMetadata();
    int width = int.parse(metadata.customMetadata!['width']!);
    int height = int.parse(metadata.customMetadata!['height']!);
    Uint8List? bytes = await _folderRef.child('${swatchId}_$imgId.jpg').getData();
    if(bytes != null) {
      List<String> labels = metadata.customMetadata!['labels']!.split(';');
      return SwatchImage(id: imgId, swatchId: swatchId, width: width, height: height, bytes: bytes, labels: labels);
    }
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
  return null;
}