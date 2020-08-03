library globals;

import 'Widgets/Swatch.dart';

CurrSwatches currSwatches = CurrSwatches.instance;

class CurrSwatches {
  CurrSwatches._privateConstructor();
  static final CurrSwatches instance = CurrSwatches._privateConstructor();

  List<void Function(Swatch)> addListeners = [];
  List<void Function(Swatch)> removeListeners = [];
  List<void Function()> setListeners = [];

  List<Swatch> _currSwatches = [];

  void addListener(void Function(Swatch) addListener, void Function(Swatch) removeListener, void Function() setListener) {
    addListeners.add(addListener);
    removeListeners.add(removeListener);
    setListeners.add(setListener);
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

  void set(List<Swatch> swatches) {
    _currSwatches = swatches;
    for(void Function() listener in setListeners) {
      if(listener != null) {
        listener();
      }
    }
  }

  List<Swatch> get currSwatches { return _currSwatches; }

  int get length { return _currSwatches.length; }
}

String model = '';

//settings
final String appName = 'Makeup App';
final String appVersion = '0.1';
final List<String> languages = ['English'];
String language = 'English';
final List<String> sortOptions = ['Color', 'Finish', 'Palette'];
String sort = 'Color';
