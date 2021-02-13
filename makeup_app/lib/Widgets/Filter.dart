enum FilterType {
  EqualTo,
  NotEqualTo,
  LessThan,
  LessThanOrEqualTo,
  GreaterThan,
  GreaterThanOrEqualTo,
}

class Filter<T> {
  final FilterType type;
  final String attribute;
  final T threshold;

  Filter(this.type, this.attribute, this.threshold);

  bool contains(T value) {
    switch(type) {
      case FilterType.EqualTo: {
        return value == threshold;
      }
      case FilterType.NotEqualTo: {
        return value != threshold;
      }
      case FilterType.LessThan: {
        if(value is num) {
          return num.parse(value.toString()) < num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.LessThanOrEqualTo: {
        if(value is num) {
          return num.parse(value.toString()) <= num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.GreaterThan: {
        if(value is num) {
          return num.parse(value.toString()) > num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.GreaterThanOrEqualTo: {
        if(value is num) {
          return num.parse(value.toString()) >= num.parse(threshold.toString());
        }
        return false;
      }
    }
    return false;
  }
}