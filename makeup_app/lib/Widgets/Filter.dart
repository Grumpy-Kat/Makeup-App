enum FilterType {
  None,
  EqualTo,
  NotEqualTo,
  LessThan,
  LessThanOrEqualTo,
  GreaterThan,
  GreaterThanOrEqualTo,
  ContainedIn,
  Contains,
}

class Filter<T> {
  final FilterType type;
  final String attribute;
  T threshold;

  Filter(this.type, this.attribute, this.threshold);

  bool contains(dynamic value) {
    switch(type) {
      case FilterType.None: {
        return true;
      }
      case FilterType.EqualTo: {
        return value == threshold;
      }
      case FilterType.NotEqualTo: {
        return value != threshold;
      }
      case FilterType.LessThan: {
        if(threshold is num && value is num) {
          return num.parse(value.toString()) < num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.LessThanOrEqualTo: {
        if(threshold is num && value is num) {
          return num.parse(value.toString()) <= num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.GreaterThan: {
        if(threshold is num && value is num) {
          return num.parse(value.toString()) > num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.GreaterThanOrEqualTo: {
        if(threshold is num && value is num) {
          return num.parse(value.toString()) >= num.parse(threshold.toString());
        }
        return false;
      }
      case FilterType.ContainedIn: {
        if(value is List) {
          return value.contains(threshold);
        }
        return false;
      }
      case FilterType.Contains: {
        if(threshold is List) {
          return (threshold as List).contains(value);
        }
        return false;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'Filter $attribute $type $threshold';
  }
}