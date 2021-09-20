import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';

class BackButton extends StatelessWidget {
  final OnVoidAction? onPressed;

  BackButton({ Key? key, required this.onPressed }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints.tight(const Size.fromWidth(26)),
      icon: Icon(
        Icons.arrow_back_ios,
        size: 19,
        color: theme.iconTextColor,
      ),
      onPressed: onPressed,
    );
  }
}
