class Look {
  String id = '';
  String name = 'Look';
  List<int> swatches = [];

  Look({ required this.id, required this.name, required this.swatches });

  Look.copy(Look other) {
    id = '';
    name = other.name;
    swatches = other.swatches.toList();
  }

  int compareTo(Look other, List<double> Function(Look) comparator) {
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
    if(!(other is Look)) {
      return false;
    }
    //return name == other.name && swatches == other.swatches;
    return id == other.id;
  }

  @override
  String toString() {
    return '$id $name $swatches';
  }

  @override
  int get hashCode => super.hashCode;
}