import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorSorting.dart';
import 'Widgets/Swatch.dart';
import 'types.dart';
import 'settingsIO.dart' as IO;
import 'allSwatchesIO.dart' as allSwatches;
import 'localizationIO.dart';

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

//user id, used for locating saved swatches and looks in Firestore
String _userID = '';
String get userID => _userID;
set userID(String value) {
  _userID = value;
  IO.save();
}

//has done initial tutorial
bool _hasDoneTutorial = false;
bool get hasDoneTutorial => _hasDoneTutorial;
set hasDoneTutorial(bool value) {
  _hasDoneTutorial = value;
  IO.save();
}

//languages
String _language = 'en';
String get language => _language;
set language(String value) {
  _language = value;
  setLanguage(value);
  IO.save();
}

//default sort and sort options
String _sort = 'sort_hue';
String get sort => _sort == '' ? 'sort_hue' : _sort;
set sort(String value) {
  _sort = value;
  IO.save();
}
Map<String, OnSortSwatch> defaultSortOptions(List<List<Swatch>> swatches, { step: 16 }) {
  return {
    'sort_hue': (Swatch swatch, int i) { return stepSort(swatch.color, step: step); },
    'sort_lightest': (Swatch swatch, int i) { return lightestSort(swatch, step: step); },
    'sort_darkest': (Swatch swatch, int i) { return darkestSort(swatch, step: step); },
    'sort_finish': (Swatch swatch, int i) { return finishSort(swatch, step: step); },
    'sort_palette': (Swatch swatch, int i) { return paletteSort(swatch, swatches[i], step: step); },
    'sort_brand': (Swatch swatch, int i) { return brandSort(swatch, swatches[i], step: step); },
    'sort_highestRated': (Swatch swatch, int i) { return highestRatedSort(swatch, step: step); },
    'sort_lowestRated': (Swatch swatch, int i) { return lowestRatedSort(swatch, step: step); },
  };
}
Map<String, OnSortSwatch> distanceSortOptions(List<List<Swatch>> swatches, RGBColor color, { step: 16 }) {
  return {
    'sort_hue': (Swatch swatch, int i) { return distanceSort(swatch.color, color); },
    'sort_lightest': (Swatch swatch, int i) { return lightestSort(swatch, step: step); },
    'sort_darkest': (Swatch swatch, int i) { return darkestSort(swatch, step: step); },
    'sort_finish': (Swatch swatch, int i) { return finishSort(swatch, step: step); },
    'sort_palette': (Swatch swatch, int i) { return paletteSort(swatch, swatches[i], step: step); },
    'sort_brand': (Swatch swatch, int i) { return brandSort(swatch, swatches[i], step: step); },
    'sort_highestRated': (Swatch swatch, int i) { return highestRatedSort(swatch, step: step); },
    'sort_lowestRated': (Swatch swatch, int i) { return lowestRatedSort(swatch, step: step); },
  };
}

//all eyeshadow tags
List<String> _tags = ['tags_pigmented', 'tags_sheer', 'tags_lotsFallout', 'tags_noFallout', 'tags_soft', 'tags_creamy', 'tags_dry'];
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
final Map<AutoShadeNameMode, String> autoShadeNameModeNames = {AutoShadeNameMode.ColLetters: getString( 'nameMode_column'), AutoShadeNameMode.RowLetters: getString('nameMode_row'), AutoShadeNameMode.None: getString('nameMode_none')};
final Map<AutoShadeNameMode, String> autoShadeNameModeDescriptions = {AutoShadeNameMode.ColLetters: getString('nameDescription_column'), AutoShadeNameMode.RowLetters: getString('nameDescription_row'), AutoShadeNameMode.None: getString('nameDescription_none')};
AutoShadeNameMode _autoShadeNameMode = AutoShadeNameMode.ColLetters;
AutoShadeNameMode get autoShadeNameMode => _autoShadeNameMode;
set autoShadeNameMode(AutoShadeNameMode value) {
   _autoShadeNameMode = value;
   IO.save();
}

//brightness offset for making new swatches from photos
int _brightnessOffset = 0;
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