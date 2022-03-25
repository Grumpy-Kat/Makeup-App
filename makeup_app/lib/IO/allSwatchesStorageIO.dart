import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as image;
import 'dart:io';
import 'dart:typed_data';
import '../Data/SwatchImage.dart';
import '../globals.dart' as globals;

late Reference _folderRef;

Map<int, Map<String, SwatchImage>> swatchImgs = {};

void init() {
  swatchImgs = {};
  _folderRef = FirebaseStorage.instance.ref('swatchesImgs/${globals.userID}');
  //getAllImgs();
}

Future<String> addImg({ required File file, required int swatchId, required List<String> labels, List<String>? otherImgIds, bool shouldCompress = true }) async {
  try {
    return await addImgBytes(bytes: file.readAsBytesSync(), swatchId: swatchId, labels: labels, otherImgIds: otherImgIds, shouldCompress: shouldCompress);
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
  return '0';
}

Future<String> addImgBytes({ required Uint8List bytes, required int swatchId, required List<String> labels, List<String>? otherImgIds, bool shouldCompress = true }) async {
  int imgId = 0;

  try {
    if(otherImgIds != null && otherImgIds.length > 0) {
      String lastId = '';
      int i = otherImgIds.length;
      do {
        i--;
        lastId = otherImgIds[i];
      } while(lastId == '' && i > 0);
      imgId = (int.tryParse(lastId) ?? -1) + 1;
    }

    image.Image fileImg = image.decodeImage(bytes.toList())!;
    if(shouldCompress) {
      fileImg = image.copyResize(fileImg, height: 250);
    }
    bytes = Uint8List.fromList(image.encodeJpg(fileImg, quality: shouldCompress ? 75 : 100));

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

    _addCacheImg(
      swatchId,
      imgId.toString(),
      SwatchImage(
        swatchId: swatchId,
        id: imgId.toString(),
        labels: labels,
        bytes: bytes,
        width: fileImg.width,
        height: fileImg.height,
      ),
    );
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }

  return imgId.toString();
}

// Most likely don't need to compress because already compressed
Future<void> updateImg({ required SwatchImage swatchImg, bool shouldCompress = false }) async {
  try {
    image.Image fileImg = image.decodeImage(swatchImg.bytes.toList())!;
    if(shouldCompress) {
      fileImg = image.copyResize(fileImg, height: 250);
    }
    Uint8List bytes = Uint8List.fromList(image.encodeJpg(fileImg, quality: shouldCompress ? 75 : 100));

    String labelsCombined = '';
    for(int i = 0; i < swatchImg.labels.length; i++) {
      labelsCombined += '${swatchImg.labels[i]};';
    }
    int width = fileImg.width;
    int height = fileImg.width;
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String> {
        'userId': globals.userID,
        'width': width.toString(),
        'height': height.toString(),
        'labels': labelsCombined,
      },
    );

    await _folderRef.child('${swatchImg.swatchId}_${swatchImg.id}.jpg').putData(bytes, metadata);

    if(swatchImg.width == null) {
      // Properly set width in cases such as AddPaletteDividerState
      swatchImg = SwatchImage(
        swatchId: swatchImg.swatchId,
        id: swatchImg.id,
        bytes: swatchImg.bytes,
        labels: swatchImg.labels,
        width: width,
        height: height,
      );
    }

    if(!_updateCacheImg(swatchImg.swatchId ?? 0, swatchImg.id, swatchImg)) {
      _addCacheImg(swatchImg.swatchId ?? 0, swatchImg.id, swatchImg);
    }
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
}

Future<void> deleteImg({ required int swatchId, required String imgId }) async {
  try {
    await _folderRef.child('${swatchId}_$imgId.jpg').delete();

    _removeCacheImg(swatchId, imgId);
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }
}

Future<void> deleteAllImgs() async {
  List<Reference> imgs = (await _folderRef.listAll()).items;
  for(Reference img in imgs) {
    try {
      img.delete();
    } on FirebaseException catch(e) {
      print('${e.code} ${e.message}');
    }
  }

  swatchImgs = {};
}

Future<SwatchImage?> getImg({ required int swatchId, required String imgId }) async {
  SwatchImage? img = _getCacheImg(swatchId, imgId);
  if(img != null) {
    return img;
  }

  try {
    FullMetadata metadata = await _folderRef.child('${swatchId}_$imgId.jpg').getMetadata();
    int width = int.parse(metadata.customMetadata!['width']!);
    int height = int.parse(metadata.customMetadata!['height']!);
    Uint8List? bytes = await _folderRef.child('${swatchId}_$imgId.jpg').getData();
    if(bytes != null) {
      List<String> labels = metadata.customMetadata!['labels']!.split(';');
      SwatchImage img = SwatchImage(id: imgId, swatchId: swatchId, width: width, height: height, bytes: bytes, labels: labels);
      _addCacheImg(swatchId, imgId, img);
      return img;
    }
  } on FirebaseException catch(e) {
    print('${e.code} ${e.message}');
  }

  return null;
}

Future<List<SwatchImage?>> getAllImgs() async {
  List<Reference> imgs = (await _folderRef.listAll()).items;
  return await Future.wait(
    imgs.map(
      (Reference img) async {
        try {
          int swatchId = int.parse(img.name.split('_')[0]);
          String imgId = img.name.split('_')[1].split('.')[0];

          SwatchImage? swatchImage = _getCacheImg(swatchId, imgId);
          if(swatchImage != null) {
            return swatchImage;
          }

          FullMetadata metadata = await img.getMetadata();
          int width = int.parse(metadata.customMetadata!['width']!);
          int height = int.parse(metadata.customMetadata!['height']!);
          Uint8List? bytes = await img.getData();

          if(bytes != null) {
            List<String> labels = metadata.customMetadata!['labels']!.split(';');
            swatchImage = SwatchImage(id: imgId, swatchId: swatchId, width: width, height: height, bytes: bytes, labels: labels);
            _addCacheImg(swatchId, imgId, swatchImage);
            return swatchImage;
          }
        } on FirebaseException catch(e) {
          print('${e.code} ${e.message}');
        }

        return null;
      }
    ),
  );
}

bool _updateCacheImg(int swatchId, String imgId, SwatchImage val) {
  if(swatchImgs.containsKey(swatchId)) {
    Map<String, SwatchImage> swatch = swatchImgs[swatchId]!;

    if(swatch.containsKey(imgId)) {
      swatch[imgId] = val;
      return true;
    }
  }

  return false;
}

void _addCacheImg(int swatchId, String imgId, SwatchImage val) {
  if(swatchImgs.containsKey(swatchId)) {
    swatchImgs[swatchId]![imgId] = val;
  } else {
    swatchImgs[swatchId] = { imgId: val };
  }
}

void _removeCacheImg(int swatchId, String imgId) {
  if(swatchImgs.containsKey(swatchId)) {
    Map<String, SwatchImage> swatch = swatchImgs[swatchId]!;

    if(swatch.containsKey(imgId)) {
      swatch.remove(imgId);
    }
  }
}

SwatchImage? _getCacheImg(int swatchId, String imgId) {
  if(swatchImgs.containsKey(swatchId)) {
    Map<String, SwatchImage> swatch = swatchImgs[swatchId]!;

    if(swatch.containsKey(imgId)) {
      return swatch[imgId];
    }
  }

  return null;
}