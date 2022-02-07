import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';
import 'StarRating.dart';

class StarField extends StatefulWidget {
  final String label;
  final int? value;
  final OnIntAction onChange;

  final EdgeInsets? labelPadding;
  final EdgeInsets? starFieldPadding;

  final bool isEditing;

  StarField({ required this.label, this.value, required this.onChange, this.isEditing = true, this.labelPadding, this.starFieldPadding });

  @override
  StarFieldState createState() => StarFieldState();
}

class StarFieldState extends State<StarField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget> [
        Container(
          height: 55,
          alignment: Alignment.centerLeft,
          padding: widget.labelPadding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Text(
            '${widget.label}: ${(widget.value == null ? 0 : widget.value)}/10',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),

        Container(
          height: 50,
          padding: widget.starFieldPadding ?? const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: StarRating(
            starCount: 10,
            starSize: 35,
            rating: (widget.value == null ? 0 : widget.value!),
            onChange: (int rating) {
              if(widget.isEditing) {
                setState(() { widget.onChange(rating); });
              }
            },
          ),
        ),
      ],
    );
  }
}
