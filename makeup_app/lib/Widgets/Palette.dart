import 'Swatch.dart';

class Palette {
  String id = '';
  String brand = '';
  String name = '';
  double weight = 0;
  double price = 0;
  List<Swatch> swatches = [];

  Palette({ required this.id, required this.brand, required this.name, required this.swatches, this.weight = 0, this.price = 0 });

  int compareTo(Palette other, List<double> Function(Palette) comparator) {
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
    if(!(other is Palette)) {
      return false;
    }
    //return name == other.name && swatches == other.swatches;
    return id == other.id;
  }

  @override
  String toString() {
    return '$id $brand $name $swatches';
  }

  @override
  int get hashCode => super.hashCode;
}