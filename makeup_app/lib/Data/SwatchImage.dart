import 'dart:typed_data';

class SwatchImage {
  final String id;
  final int? swatchId;

  final int? width;
  final int? height;
  Uint8List bytes = Uint8List(0);

  List<String> labels = [];

  SwatchImage({ required this.id, this.swatchId, this.width, this.height, required this.bytes, required this.labels });
}