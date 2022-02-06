import '../ColorMath/ColorObjects.dart';

class Swatch {
  int id;
  RGBColor color;
  String colorName;
  String finish;
  String brand;
  String palette;
  String shade = '';

  double weight = 0.0;
  double price = 0.0;

  int rating = 5;
  List<String>? tags = [];

  List<String>? imgIds = [];

  DateTime? openDate = DateTime.now();
  DateTime? expirationDate = DateTime.now();

  Swatch({ required this.color, required this.finish, this.id = -1, this.colorName = '', this.brand = '', this.palette = '', this.shade = '', this.weight = 0.0, this.price = 0.0, this.rating = 5, this.tags, this.imgIds, this.openDate, this.expirationDate });

  int compareTo(Swatch other, List<double> Function(Swatch) comparator) {
    List<double> thisValues = comparator(this);
    List<double> otherValues = comparator(other);
    for(int i = 0; i < thisValues.length; i++) {
      int comp = thisValues[i].compareTo(otherValues[i]);
      if(comp != 0) {
        return comp;
      }
    }
    return 0;
  }

  bool operator ==(other) {
    if(!(other is Swatch)) {
      return false;
    }
    //return id == other.id && color == other.color && finish == other.finish && brand == other.brand && palette == other.palette && shade == other.shade && rating == other.rating && tags == other.tags;
    return id == other.id;
  }
  
  Map<String, dynamic> getMap() {
    return {
      'color': color,
      'colorName': colorName.trim(),
      'finish': finish,
      'brand': brand.trim(),
      'palette': palette.trim(),
      'shade': shade.trim(),
      'weight': weight,
      'price': price,
      'rating': rating,
      'tags': tags,
      'imgIds': imgIds,
      'openDate': openDate,
      'expirationDate': expirationDate,
    };
  }

  @override
  String toString() {
    return '$id $color $finish $brand $palette $shade';
  }

  @override
  int get hashCode => super.hashCode;
}