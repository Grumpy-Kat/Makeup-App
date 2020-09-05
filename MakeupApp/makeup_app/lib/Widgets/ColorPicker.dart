import 'package:flutter/material.dart' hide HSVColor;
import 'dart:math';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../theme.dart' as theme;

class ColorPicker extends StatefulWidget {
  final void Function(double, double, double) onEnter;
  final String btnText;
  final HSVColor initialColor;

  ColorPicker({Key key, @required this.onEnter, this.btnText = 'Find Colors', this.initialColor }) : super(key: key);

  @override
  ColorPickerState createState() => ColorPickerState();
}

class ColorPickerState extends State<ColorPicker> {
  final List<Color> hueColors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 0, 0),
  ];
  final List<Color> saturationColors = [
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(0, 255, 255, 255),
  ];
  final List<Color> valueColors = [
    const Color.fromARGB(255, 0, 0, 0),
    const Color.fromARGB(255, 255, 255, 255),
  ];

  double hue = 0;
  double saturation = 1;
  double value = 1;

  @override
  void initState() {
    super.initState();
    if(widget.initialColor != null) {
      List<double> values = widget.initialColor.getValues();
      hue = values[0];
      saturation = values[1];
      value = values[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double wheelDiameter = size.height * 0.225;
    Size sliderSize = Size(wheelDiameter, size.height * 0.03);
    List<int> rgb = HSVtoRGB(HSVColor(hue, saturation, value)).getUpscaledValues();
    return Stack(
      children: <Widget>[
        Positioned(
          width: wheelDiameter,
          height: wheelDiameter,
          top: size.height * 0.025,
          left: ((size.width * 0.8) - wheelDiameter) / 2,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: hueColors,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: saturationColors,
                ),
              ),
              child: GestureDetector(
                onTapDown: (TapDownDetails details) { onWheelChange(details.globalPosition, wheelDiameter / 2); },
                onPanUpdate: (DragUpdateDetails details) { onWheelChange(details.globalPosition, wheelDiameter / 2); },
                child: CustomPaint(
                  painter: _WheelPickerPainter(
                    radius: wheelDiameter / 2,
                    center: Offset(wheelDiameter / 2, size.height * 0.125),
                    hue: hue,
                    saturation: saturation,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          width: sliderSize.width,
          height: sliderSize.height,
          top: size.height * 0.265,
          left: ((size.width * 0.8) - wheelDiameter) / 2,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
              gradient: LinearGradient(
                colors: valueColors,
              ),
            ),
            child: GestureDetector(
              onTapDown: (TapDownDetails details) { onSliderChange(details.globalPosition, sliderSize); },
              onPanUpdate: (DragUpdateDetails details) { onSliderChange(details.globalPosition, sliderSize); },
              child: CustomPaint(
                painter: _SliderPickerPainter(
                  size: sliderSize,
                  value: value,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          width: size.width * 0.2,
          height: size.height * 0.27,
          top: size.height * 0.025,
          left: size.width * 0.77,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1),
            ),
          ),
        ),
        Positioned(
          width: size.width * 0.35,
          height: 45,
          top: size.height * 0.325,
          left: size.width * 0.325,
          child: FlatButton(
            color: theme.accentColor,
            onPressed: () { widget.onEnter(hue, saturation, value); },
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.btnText,
                style: theme.accentTextSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onWheelChange(Offset pos, double radius) {
    setState(() {
      double x = pos.dx - (MediaQuery.of(context).size.width * 0.4);
      double y = pos.dy - ((MediaQuery.of(context).size.height * 0.125) + radius);
      hue = (atan2(-y / radius, -x / radius) * (180 / pi)) + 180;
      saturation = max(0, min(1, sqrt(x * x + y * y) / radius));
    });
  }

  void onSliderChange(Offset pos, Size size) {
    setState(() {
      double x = pos.dx - ((MediaQuery.of(context).size.width * 0.4) - (size.width / 2));
      value = max(0, min(1, x / size.width));
    });
  }
}

class _WheelPickerPainter extends CustomPainter {
  final double radius;
  final Offset center;

  final double hue;
  final double saturation;

  final double pickerRadius;

  _WheelPickerPainter({@required this.radius, @required this.center, @required this.hue, @required this.saturation, this.pickerRadius = 10});

  @override
  void paint(Canvas canvas, Size size) {
    Offset pos = Offset(cos(hue * (pi / -180)) * saturation * radius + center.dx, sin(hue * (pi / -180)) * saturation * -radius + center.dy - (pickerRadius * 2));
    final Paint paintBlack = Paint();
    paintBlack.color = Colors.black;
    paintBlack.strokeWidth = 5;
    paintBlack.style = PaintingStyle.stroke;
    canvas.drawCircle(pos, pickerRadius, paintBlack);
    final Paint paintWhite = Paint();
    paintWhite.color = Colors.white;
    paintWhite.strokeWidth = 3;
    paintWhite.style = PaintingStyle.stroke;
    canvas.drawCircle(pos, pickerRadius, paintWhite);
    final Paint paintColor = Paint();
    List<int> rgb = HSVtoRGB(HSVColor(hue, saturation, 1)).getUpscaledValues();
    paintColor.color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    paintColor.style = PaintingStyle.fill;
    canvas.drawCircle(pos, pickerRadius - 1, paintColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _SliderPickerPainter extends CustomPainter {
  final Size size;

  final double value;

  final double pickerRadius;

  _SliderPickerPainter({@required this.size, @required this.value, this.pickerRadius = 10});

  @override
  void paint(Canvas canvas, Size size) {
    Offset pos = Offset(size.width * value, size.height / 2);
    final Paint paintBlack = Paint();
    paintBlack.color = Colors.black;
    paintBlack.strokeWidth = 5;
    paintBlack.style = PaintingStyle.stroke;
    canvas.drawCircle(pos, pickerRadius, paintBlack);
    final Paint paintWhite = Paint();
    paintWhite.color = Colors.white;
    paintWhite.strokeWidth = 3;
    paintWhite.style = PaintingStyle.stroke;
    canvas.drawCircle(pos, pickerRadius, paintWhite);
    final Paint paintColor = Paint();
    int rgb = (value * 255).toInt();
    paintColor.color = Color.fromARGB(255, rgb, rgb, rgb);
    paintColor.style = PaintingStyle.fill;
    canvas.drawCircle(pos, pickerRadius - 1, paintColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
