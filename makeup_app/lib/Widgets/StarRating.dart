import 'package:flutter/material.dart';
import '../types.dart';
import '../theme.dart' as theme;

class StarRating extends StatelessWidget {
  final int starCount;
  final double starSize;
  final int rating;
  final OnIntAction? onChange;

  const StarRating({ this.starCount = 5, this.starSize = 30, this.rating = 1, this.onChange });

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [];
    for(int i = 0; i < starCount; i++) {
      row.add(buildStar(context, i));
    }
    return Row(
      children: row,
    );
  }

  Widget buildStar(BuildContext context, int i) {
    Icon icon;
    if(i >= rating) {
      icon = Icon(
        Icons.star_border,
        size: starSize,
        color: theme.primaryColorDark,
      );
    } else {
      icon = Icon(
        Icons.star,
        size: starSize,
        color: theme.accentColor,
      );
    }
    return Expanded(
      child: InkResponse(
        onTap: () { if(onChange != null) onChange!(i + 1); },
        child: icon,
      ),
    );
  }
}