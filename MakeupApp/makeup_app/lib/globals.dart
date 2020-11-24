import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorSorting.dart';
import 'Widgets/Swatch.dart';
import 'types.dart';
import 'settingsIO.dart' as IO;
import 'allSwatchesIO.dart' as allSwatches;

//curr swatches in today's look
CurrSwatches currSwatches = CurrSwatches.instance;

class CurrSwatches {
  CurrSwatches._privateConstructor();
  static final CurrSwatches instance = CurrSwatches._privateConstructor();

  Map<int, OnIntAction> addListeners = {};
  Map<int, OnIntAction> removeListeners = {};
  Map<int, OnVoidAction> setListeners = {};

  List<int> _currSwatches = [];

  void init() {
    allSwatches.listenOnSaveChanged(validateAll);
  }

  int addListener(OnIntAction addListener, OnIntAction removeListener, OnVoidAction setListener) {
    int i = addListeners.length;
    addListeners[i] = addListener;
    removeListeners[i] = removeListener;
    setListeners[i] = setListener;
    return i;
  }

  void removeListener(int i) {
    addListeners.remove(i);
    removeListeners.remove(i);
    setListeners.remove(i);
  }

  void add(int swatch) {
    if(!_currSwatches.contains(swatch) && allSwatches.isValid(swatch)) {
      _currSwatches.add(swatch);
      for(OnIntAction listener in addListeners.values) {
        if(listener != null) {
          listener(swatch);
        }
      }
    }
  }

  void addMany(List<int> swatches) {
    for(int i = 0; i < swatches.length; i++) {
      if(!_currSwatches.contains(swatches[i]) && allSwatches.isValid(swatches[i])) {
        _currSwatches.add(swatches[i]);
      }
    }
    for(OnIntAction listener in addListeners.values) {
      if(listener != null) {
        listener(swatches.last);
      }
    }
  }

  void remove(int swatch) {
    if(_currSwatches.contains(swatch)) {
      _currSwatches.remove(swatch);
      for(OnIntAction listener in removeListeners.values) {
        if(listener != null) {
          listener(swatch);
        }
      }
    }
  }

  void set(List<int> swatches) {
    _currSwatches = swatches.toSet().toList();
    validateAll();
    for(OnVoidAction listener in setListeners.values) {
      if(listener != null) {
        listener();
      }
    }
  }

  void validateAll() {
    //check to see if all swatches are valid
    for(int i = _currSwatches.length - 1; i >= 0; i--) {
      if(!allSwatches.isValid(_currSwatches[i])) {
        _currSwatches.removeAt(i);
      }
    }
  }

  List<int> get currSwatches {
    return _currSwatches;
  }

  int get length { return currSwatches.length; }
}

//finish prediction model
String model = '';

//has settings loaded and listener
bool _hasLoaded = false;
bool get hasLoaded => _hasLoaded;
set hasLoaded(bool value) {
  if(!_hasLoaded && value) {
    for(OnVoidAction listener in _hasLoadedListeners) {
      if(listener != null) {
        listener();
      }
    }
    _hasLoadedListeners.clear();
  }
  _hasLoaded = value;
}

List<OnVoidAction> _hasLoadedListeners = [];

void addHasLoadedListener(OnVoidAction hasLoadedListener) {
  if(!_hasLoaded) {
    _hasLoadedListeners.add(hasLoadedListener);
  }
}

//settings
//basic app info
final String appName = 'GlamKit';
final String appVersion = '0.4';
bool debug = true;

//has done initial tutorial
bool _hasDoneTutorial = false;
bool get hasDoneTutorial => _hasDoneTutorial;
set hasDoneTutorial(bool value) {
  _hasDoneTutorial = value;
  IO.save();
}

//languages
final List<String> languages = ['English', 'Spanish'];
String _language = 'English';
String get language => _language;
set language(String value) {
  if(languages.contains(value)) {
    _language = value;
    IO.save();
  }
}

//default sort and sort options
String _sort = 'Hue';
String get sort => _sort == '' ? 'Hue' : _sort;
set sort(String value) {
  _sort = value;
  IO.save();
}
Map<String, OnSortSwatch> defaultSortOptions(List<List<Swatch>> swatches, { step: 16 }) {
  return {
    'Hue': (Swatch swatch, int i) { return stepSort(swatch.color, step: step); },
    'Lightest': (Swatch swatch, int i) { return lightestSort(swatch, step: step); },
    'Darkest': (Swatch swatch, int i) { return darkestSort(swatch, step: step); },
    'Finish': (Swatch swatch, int i) { return finishSort(swatch, step: step); },
    'Palette': (Swatch swatch, int i) { return paletteSort(swatch, swatches[i], step: step); },
    'Brand': (Swatch swatch, int i) { return brandSort(swatch, swatches[i], step: step); },
    'Highest Rated': (Swatch swatch, int i) { return highestRatedSort(swatch, step: step); },
    'Lowest Rated': (Swatch swatch, int i) { return lowestRatedSort(swatch, step: step); },
  };
}
Map<String, OnSortSwatch> distanceSortOptions(List<List<Swatch>> swatches, RGBColor color, { step: 16 }) {
  return {
    'Hue': (Swatch swatch, int i) { return distanceSort(swatch.color, color); },
    'Lightest': (Swatch swatch, int i) { return lightestSort(swatch, step: step); },
    'Darkest': (Swatch swatch, int i) { return darkestSort(swatch, step: step); },
    'Finish': (Swatch swatch, int i) { return finishSort(swatch, step: step); },
    'Palette': (Swatch swatch, int i) { return paletteSort(swatch, swatches[i], step: step); },
    'Brand': (Swatch swatch, int i) { return brandSort(swatch, swatches[i], step: step); },
    'Highest Rated': (Swatch swatch, int i) { return highestRatedSort(swatch, step: step); },
    'Lowest Rated': (Swatch swatch, int i) { return lowestRatedSort(swatch, step: step); },
  };
}

//all eyeshadow tags
List<String> _tags = ['Pigmented', 'Sheer', 'Lots of Fallout', 'No Fallout', 'Creamy', 'Dry'];
List<String> get tags => _tags;
set tags(List<String> value) {
  _tags = value.toSet().toList();
  IO.save();
}

//auto shade name lettering for new palettes
enum AutoShadeNameMode {
  ColLetters,
  RowLetters,
  None,
}
final Map<AutoShadeNameMode, String> autoShadeNameModeNames = {AutoShadeNameMode.ColLetters: 'Column Letters', AutoShadeNameMode.RowLetters: 'Row Letters', AutoShadeNameMode.None: 'None'};
final Map<AutoShadeNameMode, String> autoShadeNameModeDescriptions = {AutoShadeNameMode.ColLetters: 'Columns will be assigned letters and rows will be assigned numbers.', AutoShadeNameMode.RowLetters: 'Columns will be assigned numbers and rows will be assigned letters.', AutoShadeNameMode.None: 'Will not auto assign a shade name.'};
AutoShadeNameMode _autoShadeNameMode = AutoShadeNameMode.ColLetters;
AutoShadeNameMode get autoShadeNameMode => _autoShadeNameMode;
set autoShadeNameMode(AutoShadeNameMode value) {
   _autoShadeNameMode = value;
   IO.save();
}

//brightness offset for making new swatches from photos
int _brightnessOffset = 30;
int get brightnessOffset => _brightnessOffset;
set brightnessOffset(int value) {
  _brightnessOffset = value.clamp(-255, 255);
  IO.save();
}

//red offset for making new swatches from photos
int _redOffset = 0;
int get redOffset => _redOffset;
set redOffset(int value) {
  _redOffset = value.clamp(-255, 255);
  IO.save();
}

//green offset for making new swatches from photos
int _greenOffset = 0;
int get greenOffset => _greenOffset;
set greenOffset(int value) {
  _greenOffset = value.clamp(-255, 255);
  IO.save();
}

//blue offset for making new swatches from photos
int _blueOffset = 0;
int get blueOffset => _blueOffset;
set blueOffset(int value) {
  _blueOffset = value.clamp(-255, 255);
  IO.save();
}

//color distance for ColorWheelScreen
double _colorWheelDistance = 13;
double get colorWheelDistance => _colorWheelDistance;
set colorWheelDistance(double value) {
  _colorWheelDistance = value.clamp(3, 25);
  IO.save();
}