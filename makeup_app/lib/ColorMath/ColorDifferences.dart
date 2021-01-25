// Credit: https://github.com/zschuessler/DeltaE/

import 'dart:math';
import 'ColorConstants.dart';
import 'ColorObjects.dart';

//Implementation: http://en.wikipedia.org/wiki/Color_difference#CIE76
double deltaECie1976(LabColor color1, LabColor color2) {
    List<double> values1 = color1.getValues();
    List<double> values2 = color2.getValues();

    return sqrt(pow(values1[0] - values2[0], 2) + pow(values1[1] - values2[1], 2) + pow(values1[2] - values2[2], 2));
}

// Implementation: http://en.wikipedia.org/wiki/Color_difference#CIE94
double deltaECie1994(LabColor color1, LabColor color2, { int kl = 1, int kc = 1, int kh = 1, double k1 = 0.045, double k2 = 0.015 }) {
  List<double> values1 = color1.getValues();
  List<double> values2 = color2.getValues();

  double finalL = (values1[0] - values2[0]) / kl;

  double c1 = sqrt(pow(values1[1], 2) + pow(values1[2], 2));
  double c2 = sqrt(pow(values2[1], 2) + pow(values2[2], 2));
  double cab = c1 - c2;
  double sc = 1 + (k1 * c1);
  double finalC = cab / (kc * sc);

  double a = values1[1] - values2[1];
  double b = values1[2] - values2[2];
  double hab = sqrt(pow(a, 2) + pow(b, 2) - pow(cab, 2));
  double sh = 1 + (k2 * c1);
  double finalH = hab / sh;

  return sqrt(pow(finalL, 2) + pow(finalC, 2) + pow(finalH, 2));
}

//Implementation: http://en.wikipedia.org/wiki/Color_difference#CIEDE2000
double deltaECie2000(LabColor color1, LabColor color2, { int kl = 1, int kc = 1, int kh = 1 }) {
  List<double> values1 = color1.getValues();
  List<double> values2 = color2.getValues();

  double lBar = (values1[0] + values2[0]) / 2;

  double c1 = sqrt(pow(values1[1], 2) + pow(values1[2], 2));
  double c2 = sqrt(pow(values2[1], 2) + pow(values2[2], 2));
  double cBar = (c1 + c2) / 2;

  double aPrime1 = values1[1] + (values1[1] / 2) * (1 - sqrt(pow(cBar, 7) / (pow(cBar, 7) + CIE_2000)));
  double aPrime2 = values2[1] + (values2[1] / 2) * (1 - sqrt(pow(cBar, 7) / (pow(cBar, 7) + CIE_2000)));

  double cPrime1 = sqrt(pow(aPrime1, 2) + pow(values1[2], 2));
  double cPrime2 = sqrt(pow(aPrime2, 2) + pow(values2[2], 2));
  double cBarPrime = (cPrime1 + cPrime2) / 2;

  double hPrime1 = _getHPrime(values1[2], aPrime1);
  double hPrime2 = _getHPrime(values2[2], aPrime2);
  double hBarPrime = _getHBarPrime(hPrime1, hPrime2);

  double deltaLPrime = values2[0] - values1[0];
  double deltaCPrime = cPrime2 - cPrime1;
  double deltaHPrime = 2 * sqrt(cPrime1 * cPrime2) * sin(_degreesToRadians(_getDeltaHPrime(c1, c2, hPrime1, hPrime2)) / 2);

  double t = 1 - 0.17 * cos(_degreesToRadians(hBarPrime - 30)) + 0.24 * cos(_degreesToRadians(2 * hBarPrime)) + 0.32 * cos(_degreesToRadians(3 * hBarPrime + 6)) - 0.20 * cos(_degreesToRadians(4 * hBarPrime - 63));

  double sSubH = 1 + 0.015 * cBarPrime * t;
  double sSubL = 1 + ((0.015 * pow(lBar - 50, 2)) / sqrt(20 + pow(lBar - 50, 2)));
  double sSubC = 1 + 0.045 * cBarPrime;

  double rSubT = -2 * sqrt(pow(cBarPrime, 7) / (pow(cBarPrime, 7) + pow(25, 7))) * sin(_degreesToRadians(60 * exp(-1 * pow((hBarPrime - 275) / 25, 2))));

  double finalL = deltaLPrime / (kl * sSubL);
  double finalC = deltaCPrime / (kc * sSubC);
  double finalH = deltaHPrime / (kh * sSubH);

  return sqrt(pow(finalL, 2) + pow(finalC, 2) + pow(finalH, 2) + rSubT * finalC * finalH);
}

double _getHBarPrime(double hPrime1, double hPrime2) {
    if((hPrime1 - hPrime2).abs() > 180) {
        return (hPrime1 + hPrime2 + 360) / 2;
    }
    return (hPrime1 + hPrime2) / 2;
}

double _getDeltaHPrime(double c1, double c2, double hPrime1, double hPrime2) {
    if(c1 == 0 || c2 == 0) {
        return 0;
    }
    if((hPrime1 - hPrime2).abs() <= 180) {
        return hPrime2 - hPrime1;
    }
    if(hPrime2 <= hPrime1) {
        return hPrime2 - hPrime1 + 360;
    } else {
        return hPrime2 - hPrime1 - 360;
    }
}

double _getHPrime(l, aPrime) {
    double hueAngle;
    if(l == 0 && aPrime == 0) {
        return 0;
    }
    hueAngle = _radiansToDegrees(atan2(l, aPrime));
    if(hueAngle >= 0) {
        return hueAngle;
    } else {
        return hueAngle + 360;
    }
}

double _radiansToDegrees(double radians) {
    return radians * (180 / pi);
}

double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
}