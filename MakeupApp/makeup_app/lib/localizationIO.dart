import 'package:flutter/services.dart' show rootBundle;
import 'types.dart';

Map<String, Map<String, String>> _localizations;
String _language = 'en';

void load() async {
  _localizations = {};
  //load and split file into lines
  String file = await rootBundle.loadString('localization/localizations.csv');
  List<String> lines = file.split('\n');
  //load languages
  List<String> languages = lines[0].split(',');
  for(int i = 1; i < languages.length; i++) {
    languages[i] = languages[i].trim();
    _localizations[languages[i]] = {};
  }
  //load ids and values for each language
  //skip line 0 because it is language ids
  for(int i = 1; i < lines.length; i++) {
    List<String> values = lines[i].split(new RegExp(r',(?!%)'));
    values[0] = values[0].trim();
    if(values[0] == '' || values[0] == ' ') {
      //no id, assuming its an empty line
      continue;
    }
    for(int j = 1; j < languages.length; j++) {
      String value = values[j].trim();
      //if value is empty, use English version
      if(value == '' || value == ' ') {
        value = values[1].trim();
      }
      //sanitize values
      value = value.replaceAll('""', '"');
      value = value.replaceAll('%', '');
      if(value[0] == '"' && value[value.length - 1] == '"') {
        value = value.substring(1, value.length - 1);
      }
      //ex: localizations['en']['lang'] = 'English'
      _localizations[languages[j]][values[0]] = value;
    }
  }
  //call listeners
  for(OnVoidAction listener in _hasLoadedListeners) {
    if(listener != null) {
      listener();
    }
  }
  _hasLoadedListeners.clear();
}

void setLanguage(String language) {
  _language = language;
}

List<String> getLanguages() {
  return _localizations.keys.toList();
}

String getString(String id, { String defaultValue = '' }) {
  return getStringOther(_language, id, defaultValue: defaultValue);
}

String getStringOther(String language, String id, { String defaultValue = '' }) {
  if(!_localizations.containsKey(language)) {
    print('Localizations does not contain a language of $language.');
    return defaultValue;
  }
  if(!_localizations[_language].containsKey(id)) {
    print('Localizations does not contain an id of $id.');
    return defaultValue;
  }
  String value = _localizations[language][id];
  //empty value, use English as default
  if(value == '' || value == ' ') {
    value = _localizations['en'][id];
  }
  return value;
}

List<OnVoidAction> _hasLoadedListeners = [];

void addHasLocalizationLoadedListener(OnVoidAction hasLoadedListener) {
  _hasLoadedListeners.add(hasLoadedListener);
}