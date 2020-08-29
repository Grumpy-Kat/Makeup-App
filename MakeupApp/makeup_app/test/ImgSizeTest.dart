import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makeupapp/Widgets/ImagePicker.dart';

void main() {
  test('(10, 10) (10, 10)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(10, 10);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, 10));
  });



  test('(10, 10) (5, 5)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(5, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, 10));
  });

  test('(10, 5) (5, 5)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(5, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(5, 10) (5, 5)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(5, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(10, 10) (5, 1)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(5, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, 2));
  });

  test('(10, 5) (5, 1)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(5, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, 2));
  });

  test('(5, 10) (5, 1)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(5, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 1));
  });

  test('(10, 10) (1, 5)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(1, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(2, 10));
  });

  test('(10, 5) (1, 5)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(1, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(1, 5));
  });

  test('(5, 10) (1, 5)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(1, 5);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(2, 10));
  });



  test('(10, 10) (15, 15)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, 10));
  });

  test('(10, 5) (15, 15)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(5, 10) (15, 15)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(10, 10) (15, 1)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, (2 / 3)));
  });

  test('(10, 5) (15, 1)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(10, (2 / 3)));
  });

  test('(5, 10) (15, 1)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, (1 / 3)));
  });

  test('(10, 10) (1, 15)', () {
    Size maxSize = Size(10, 10);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size((2 / 3), 10));
  });

  test('(10, 5) (1, 15)', () {
    Size maxSize = Size(10, 5);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size((1 / 3), 5));
  });

  test('(5, 10) (1, 15)', () {
    Size maxSize = Size(5, 10);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size((2 / 3), 10));
  });



  test('(100, 100) (15, 15)', () {
    Size maxSize = Size(100, 100);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(100, 100));
  });

  test('(100, 5) (15, 15)', () {
    Size maxSize = Size(100, 5);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(5, 100) (15, 15)', () {
    Size maxSize = Size(5, 100);
    Size actualImg = Size(15, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 5));
  });

  test('(100, 100) (15, 1)', () {
    Size maxSize = Size(100, 100);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(100, (20 / 3)));
  });

  test('(100, 5) (15, 1)', () {
    Size maxSize = Size(100, 5);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(75, 5));
  });

  test('(5, 100) (15, 1)', () {
    Size maxSize = Size(5, 100);
    Size actualImg = Size(15, 1);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, (1 / 3)));
  });

  test('(100, 100) (1, 15)', () {
    Size maxSize = Size(100, 100);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size((20 / 3), 100));
  });

  test('(100, 5) (1, 15)', () {
    Size maxSize = Size(100, 5);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size((1 / 3), 5));
  });

  test('(5, 100) (1, 15)', () {
    Size maxSize = Size(5, 100);
    Size actualImg = Size(1, 15);
    Size imgSize = ImagePicker.getScaledImgSize(maxSize, actualImg);
    expect(imgSize, Size(5, 75));
  });
}