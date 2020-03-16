// Credit: https://github.com/gtaylor/python-colormath/

import 'ColorConstants.dart';
import 'ColorObjects.dart';

List<double> dotProduct(List<List<double>> matrix, List<double> vector) {
  List<double> result = [];
  for(int i = 0; i < matrix.length; i++) {
    result.add(0);
    for (int j = 0; i < vector.length; i++) {
      result[i] += matrix[i][j] * vector[j];
    }
  }
  return result;
}

List<List<double>> dotProductMatrices(List<List<double>> matrix1, List<List<double>> matrix2) {
    List<List<double>> result = [];
    for(int i = 0; i < matrix1.length; i++) {
        result.add([]);
        for(int j = 0; j < matrix2[0].length; j++) {
            result[i].add(0);
            for (int k = 0; k < matrix1[0].length; k++) {
                result[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }
    return result;
}

List<double> applyChromaticAdaptation(double x, double y, double z, String origIlluminant, String targetIlluminant, { String observer = '2', String adaptation = 'bradford' }) {
  adaptation = adaptation.toLowerCase();
  origIlluminant = origIlluminant.toLowerCase();
  List<double> whitePointsOrig = ILLUMINANTS[observer][origIlluminant];
  targetIlluminant = targetIlluminant.toLowerCase();
  List<double> whitePointsTarget = ILLUMINANTS[observer][targetIlluminant];
  List<List<double>> transformationMatrix = _getAdaptationMatrix(whitePointsOrig, whitePointsTarget, observer, adaptation);
  return dotProduct(transformationMatrix, [x, y, z]);
}

void applyChromaticAdaptationOnColor(XYZColor color, String targetIlluminant, { String adaptation = 'bradford' }) {
  List<double> values = color.getValues();
  String origIlluminant = color.illuminant;
  targetIlluminant = targetIlluminant.toLowerCase();
  String observer = color.observer;
  adaptation = adaptation.toLowerCase();
  values = applyChromaticAdaptation(values[0], values[1], values[2], origIlluminant, targetIlluminant, observer: observer, adaptation: adaptation);
  color.values['xyzX'] = values[0];
  color.values['xyzY'] = values[1];
  color.values['xyzZ'] = values[2];
  color.setIlluminant(targetIlluminant);
}

List<List<double>> _getAdaptationMatrix(List<double> whitePointsOrig, List<double> whitePointsTarget, String observer, String adaptation) {
    List<List<double>> adaptationMatrix = ADAPTATION[adaptation];
    List<double> orig = dotProduct(adaptationMatrix, whitePointsOrig);
    List<double> target = dotProduct(adaptationMatrix, whitePointsTarget);
    int n = orig.length;

    List<List<double>> diag = [
        [target[0] / orig[0], 0, 0],
        [0, target[1] / orig[1], 0],
        [0, 0, target[2] / orig[2]],
    ];

    List<List<double>> transposedMatrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        transposedMatrix[j][i] = adaptationMatrix[i][j];
      }
    }

    List<List<double>> inverseMatrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    double determinant = _determinant(adaptationMatrix, n);
    List<List<double>> adjointMatrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    int sign = 1;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            sign = ((i+j) % 2==0) ? 1 : -1;
            adjointMatrix[j][i] = (sign * _determinant(_getCofactor(adaptationMatrix, i, j, n), n - 1)).toDouble();
            inverseMatrix[i][j] = adjointMatrix[i][j] / determinant;
        }
    }

    List<List<double>> pinvMatrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    for(int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            for(int k = 0; k < n; k++) {
                pinvMatrix[i][j] += inverseMatrix[i][k] * transposedMatrix[k][j];
            }
        }
    }

    return dotProductMatrices(dotProductMatrices(adaptationMatrix, pinvMatrix), diag);
}

double _determinant(List<List<double>> matrix, int n) {
  if(n == 1) {
      return matrix[0][0];
  }
  double determinant = 0;
  int sign = 1;
  for(int i = 0; i < n; i++) {
    determinant += sign * matrix[0][i] * _determinant(_getCofactor(matrix, 0, i, n), n - 1);
    sign = -sign;
  }
  return determinant;
}

List<List<double>> _getCofactor(List<List<double>> a, int p, int q, int n) {
  List<List<double>> temp = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
  int x = 0, y = 0;
  for(int i = 0; i < n; i++) {
     for(int j = 0; j < n; j++) {
        if(i != p && j != q) {
           temp[x][y++] = a[i][j];
           if(y == n - 1) {
              y = 0;
              x++;
           }
        }
     }
  }
  return temp;
}
