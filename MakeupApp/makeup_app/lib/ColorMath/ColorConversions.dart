// Credit: https://github.com/gtaylor/python-colormath/

import 'dart:math';
import 'ColorConstants.dart';
import 'ColorChromaticAdaptation.dart';
import 'ColorObjects.dart';

XYZColor LabtoXYZ(LabColor color) {
  Map<String, double> illuminant = color.getIlluminantXYZ();
  List<double> values = color.getValues();
  double y = (values[0] + 16.0) / 116.0;
  double x = values[1] / 500.0 + y;
  double z = y - values[2] / 200.0;

  double xPow = pow(x, 3);
  if(xPow > CIE_E) {
    x = xPow;
  } else {
    x = (x - 16.0 / 116.0) / 7.787;
  }
  double yPow = pow(y, 3);
  if(yPow > CIE_E) {
    y = yPow;
  } else {
    y = (y - 16.0 / 116.0) / 7.787;
  }
  double zPow = pow(z, 3);
  if(zPow > CIE_E) {
    z = zPow;
  } else {
    z = (z - 16.0 / 116.0) / 7.787;
  }

  x = illuminant['X'] * x;
  y = illuminant['Y'] * y;
  z = illuminant['Z'] * z;

  return XYZColor(x, y, z, observer: color.observer, illuminant: color.illuminant);
}

LabColor XYZtoLab(XYZColor color) {
  Map<String, double> illuminant = color.getIlluminantXYZ();
  List<double> values = color.getValues();
  double x = values[0] / illuminant["X"];
  double y = values[1] / illuminant["Y"];
  double z = values[2] / illuminant["Z"];

  if(x > CIE_E) {
    x = pow(x, (1.0 / 3.0));
  } else {
    x = (7.787 * x) + (16.0 / 116.0);
  }
  if(y > CIE_E) {
    y = pow(y, (1.0 / 3.0));
  } else {
    y = (7.787 * y) + (16.0 / 116.0);
  }
  if(z > CIE_E) {
    z = pow(z, (1.0 / 3.0));
  } else {
    z = (7.787 * z) + (16.0 / 116.0);
  }

  double l = (116.0 * y) - 16.0;
  double a = 500.0 * (x - y);
  double b = 200.0 * (y - z);

  return LabColor(l, a, b, observer: color.observer, illuminant: color.illuminant);
}

HSVColor RGBtoHSV(RGBColor color) {
  List<double> values = color.getValues();
  double r = values[0];
  double g = values[1];
  double b = values[2];
  double maxRGB = max(max(r, g), b);
  double minRGB = min(min(r, g), b);

  double h = 0;
  if(maxRGB == minRGB) {
    h = 0.0;
  } else if(maxRGB == r) {
    h = (60.0 * ((g - b) / (maxRGB - minRGB)) + 360) % 360.0;
  } else if(maxRGB == g) {
    h = 60.0 * ((b - r) / (maxRGB - minRGB)) + 120;
  } else {
    h = 60.0 * ((r - g) / (maxRGB - minRGB)) + 240.0;
  }

  double s = 0;
  if(maxRGB != 0) {
    s = 1.0 - (minRGB / maxRGB);
  }

  double v = maxRGB;

  return HSVColor(h, s, v);
}

RGBColor XYZtoRGB(XYZColor color) {
  Map<String, double> illuminant = color.getIlluminantXYZ();
  List<double> values = color.getValues();
  double y = (values[0] + 16.0) / 116.0;
  double x = values[1] / 500.0 + y;
  double z = y - values[2] / 200.0;

  List<double> xyz = applyChromaticAdaptation(x, y, z, color.illuminant, 'd65');
  List<double> linearChannels = _applyRGBMatrix(xyz, 'XYZtoRGB');
  List<double> nonlinearChannels = [];
  for(int i = 0; i < linearChannels.length; i++) {
    if(linearChannels[i] <= 0.0031308) {
      nonlinearChannels[i] = linearChannels[i] * 12.92;
    } else {
      nonlinearChannels[i] = 1.055 * pow(linearChannels[i], 1 / 2.4) - 0.055;
    }
  }

  return RGBColor(nonlinearChannels[0], nonlinearChannels[1], nonlinearChannels[2]);
}

LabColor RGBtoLab(RGBColor color) {
  return XYZtoLab(RGBtoXYZ(color));
}

RGBColor LabtoRGB(LabColor color) {
  return XYZtoRGB(LabtoXYZ(color));
}

RGBColor HSVtoRGB(HSVColor color) {
  List<double> values = color.getValues();
  double h = values[0];
  double s = values[1];
  double v = values[2];

  int hFloor = h.floor();
  int hSubI = ((hFloor / 60) % 6).toInt();
  double f = (h / 60.0) - (hFloor / 60).floor();
  double p = v * (1.0 - s);
  double q = v * (1.0 - f * s);
  double t = v * (1.0 - (1.0 - f) * s);

  if(hSubI == 0) {
    return RGBColor(v, t, p);
  } else if(hSubI == 1) {
    return RGBColor(q, v, p);
  } else if(hSubI == 2) {
    return RGBColor(p, v, t);
  } else if(hSubI == 3) {
    return RGBColor(p, q, v);
  } else if(hSubI == 4) {
    return RGBColor(v, t, p);
  } else if(hSubI == 5) {
    return RGBColor(v, p, q);
  } else{
    throw Exception('Unable to convert HSL->RGB due to value error.');
  }
}

XYZColor RGBtoXYZ(RGBColor color, { targetIlluminant = '' }) {
  List<double> values = color.getValues();
  List<double> linearChannels = [];
  for(int i = 0; i < values.length; i++) {
    if(values[i] <= 0.04045) {
      linearChannels.add(values[i] / 12.92);
    } else {
      linearChannels.add(pow((values[i] + 0.055) / 1.055, 2.4));
    }
  }
  List<double> xyz = _applyRGBMatrix(linearChannels, 'RGBtoXYZ');
  if(targetIlluminant == '') {
    targetIlluminant = color.nativeIlluminant;
  }
  XYZColor xyzColor = XYZColor(xyz[0], xyz[1], xyz[2], illuminant: color.nativeIlluminant);
  xyzColor.applyAdaptation(targetIlluminant);
  return xyzColor;
}

List<double> _applyRGBMatrix(List<double> xyz, String conversionType) {
  List<List<double>> rgbMatrix = RGBColor.conversionMatrices[conversionType];
  List<double> result = dotProduct(rgbMatrix, xyz);
  result[0] = max(result[0], 0);
  result[1] = max(result[1], 0);
  result[2] = max(result[2], 0);
  return result;
}
