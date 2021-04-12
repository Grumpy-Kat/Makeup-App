// Credit: https://github.com/gtaylor/python-colormath/

import 'dart:math';
import 'ColorConstants.dart';
import 'ColorExceptions.dart';
import 'ColorChromaticAdaptation.dart';

class ColorBase {
  final Map<String, double> values = {};

  List<double> getValues() {
    return values.values.toList(growable: true);
  }

  bool operator ==(other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    List<double> values = getValues();
    List<double> otherValues = (other as ColorBase).getValues();
    double threshold = 0.00001;
    //should be in same order unless something instantiated badly (which will cause any conversions or calculations to be incorrect)
    for(int i = 0; i < values.length; i++) {
      if((values[i] - otherValues[i]).abs() > threshold) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return values.toString();
  }

  @override
  int get hashCode => super.hashCode;
}

class LabColor extends ColorBase {
  String observer = '';
  String illuminant = '';

  LabColor(double labL, double labA, double labB, { String observer = "2", String illuminant = "d50" }) {
    values['labL'] = labL;
    values['labA'] = labA;
    values['labB'] = labB;
    setObserver(observer);
    setIlluminant(illuminant);
  }

  void setObserver(observer) {
    if(!OBSERVERS.contains(observer)) {
      throw InvalidObserverException(observer);
    }
    this.observer = observer;
  }

  void setIlluminant(illuminant) {
    illuminant = illuminant.toLowerCase();
    if(!ILLUMINANTS[observer]!.containsKey(illuminant)) {
      throw InvalidIlluminantException(illuminant);
    }
    this.illuminant = illuminant;
  }

  Map<String, double> getIlluminantXYZ({ observer = '', illuminant = '' }) {
    Map<String, List<double>> illuminantObserver;
    List<double> illuminantXYZ;
    try {
      if(observer == '') {
        observer = this.observer;
      }
      illuminantObserver = ILLUMINANTS[observer]!;
    } catch(e) {
      throw InvalidObserverException(observer);
    }
    try {
      if(illuminant == '') {
        illuminant = this.illuminant;
      }
      illuminantXYZ = illuminantObserver[illuminant]!;
    } catch(e) {
      throw InvalidIlluminantException(illuminant);
    }
    return { 'X': illuminantXYZ[0], 'Y': illuminantXYZ[1], 'Z': illuminantXYZ[2] };
  }
}

class XYZColor extends ColorBase {
  String observer = '';
  String illuminant = '';

  XYZColor(double xyzX, double xyzY, double xyzZ, { String observer = "2", String illuminant = "d50" }) {
    values['xyzX'] = xyzX;
    values['xyzY'] = xyzY;
    values['xyzZ'] = xyzZ;
    setObserver(observer);
    setIlluminant(illuminant);
  }

  void setObserver(observer) {
    if(!OBSERVERS.contains(observer)) {
      throw InvalidObserverException(observer);
    }
    this.observer = observer;
  }

  void setIlluminant(illuminant) {
    illuminant = illuminant.toLowerCase();
    if(!ILLUMINANTS[observer]!.containsKey(illuminant)) {
      throw InvalidIlluminantException(illuminant);
    }
    this.illuminant = illuminant;
  }

  Map<String, double> getIlluminantXYZ({ observer = '', illuminant = '' }) {
    Map<String, List<double>> illuminantObserver;
    List<double> illuminantXYZ;
    try {
      if (observer == '') {
        observer = this.observer;
      }
      illuminantObserver = ILLUMINANTS[observer]!;
    } catch (e) {
      throw InvalidObserverException(observer);
    }
    try {
      if (illuminant == '') {
        illuminant = this.illuminant;
      }
      illuminantXYZ = illuminantObserver[illuminant]!;
    } catch (e) {
      throw InvalidIlluminantException(illuminant);
    }
    return {
      'X': illuminantXYZ[0],
      'Y': illuminantXYZ[1],
      'Z': illuminantXYZ[2]
    };
  }

  void applyAdaptation(targetIlluminant, { adaptation = 'bradford' }) {
    if(illuminant != targetIlluminant) {
      applyChromaticAdaptationOnColor(this, targetIlluminant, adaptation: adaptation);
    }
  }
}

class RGBColor extends ColorBase {
  double gamma = 2.2;
  String nativeIlluminant = 'd65';
  static Map<String, List<List<double>>> conversionMatrices = {
    'XYZtoRGB': [
      [3.24071, -1.53726, -0.498571],
      [-0.969258, 1.87599, 0.0415557],
      [0.0556352, -0.203996, 1.05707],
    ],
    'RGBtoXYZ': [
      [0.412424, 0.357579, 0.180464],
      [0.212656, 0.715158, 0.0721856],
      [0.0193324, 0.119193, 0.950444],
    ]
  };

  RGBColor(double rgbR, double rgbG, double rgbB) {
    values['rgbR'] = rgbR;
    values['rgbG'] = rgbG;
    values['rgbB'] = rgbB;
  }

  RGBColor.hex(String hex) {
    hex = hex.trim();
    if(hex[0] == "#") {
      hex = hex.substring(1);
    }
    if(hex.length != 6) {
      throw ArgumentError('input $hex is not in #RRGGBB format');
    }
    values['rgbR'] = int.parse(hex.substring(0, 2), radix: 16) / 255.0;
    values['rgbR'] = int.parse(hex.substring(2, 4), radix: 16) / 255.0;
    values['rgbR'] = int.parse(hex.substring(4, 6), radix: 16) / 255.0;
  }

  double clampValue(value) {
    return min(max(value, 0.0), 1.0);
  }

  double clampedRGBR() {
    return clampValue(values['rgbR']);
  }

  double clampedRGBG() {
    return clampValue(values['rgbG']);
  }

  double clampedRGBB() {
    return clampValue(values['rgbB']);
  }

  List<int> getUpscaledValues() {
    int rgbR = (0.5 + values['rgbR']! * 255).floor();
    int rgbG = (0.5 + values['rgbG']! * 255).floor();
    int rgbB = (0.5 + values['rgbB']! * 255).floor();
    return [rgbR, rgbG, rgbB];
  }

  String getRGBHex() {
    List<int> rgb = getUpscaledValues();
    int r = rgb[0];
    int g = rgb[1];
    int b = rgb[2];
    return '#$r$g$b';
  }
}

class HSVColor extends ColorBase {
  HSVColor(double hsvH, double hsvS, double hsvV) {
    values['hsvH'] = hsvH;
    values['hsvS'] = hsvS;
    values['hsvV'] = hsvV;
  }
}
