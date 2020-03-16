library globals;

import 'Widgets/Swatch.dart';

CurrSwatches currSwatches = CurrSwatches.instance;

class CurrSwatches {
  CurrSwatches._privateConstructor();
  static final CurrSwatches instance = CurrSwatches._privateConstructor();

  List<void Function(Swatch)> addListeners = [];
  List<void Function(Swatch)> removeListeners = [];

  List<Swatch> _currSwatches = [];

  void addListener(void Function(Swatch) addListener, void Function(Swatch) removeListener) {
    addListeners.add(addListener);
    removeListeners.add(removeListener);
  }

  void add(Swatch swatch) {
    _currSwatches.add(swatch);
    for(void Function(Swatch) listener in addListeners) {
      if(listener != null) {
        listener(swatch);
      }
    }
  }

  void remove(Swatch swatch) {
    _currSwatches.remove(swatch);
    for(void Function(Swatch) listener in removeListeners) {
      if(listener != null) {
        listener(swatch);
      }
    }
  }

  List<Swatch> get currSwatches { return _currSwatches; }

  int get length { return _currSwatches.length; }
}

String model = '';