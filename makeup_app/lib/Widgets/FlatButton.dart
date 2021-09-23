import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';

class FlatButton extends StatelessWidget {
  final OnVoidAction? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final Color? bgColor;
  final Color? splashColor;

  FlatButton({ Key? key, required this.onPressed, required this.child, this.padding, this.bgColor, this.splashColor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: bgColor ?? Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(2)),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if(states.contains(MaterialState.pressed)) {
              return splashColor ?? theme.accentColor.withAlpha(130);
            }
            return null;
          },
        ),
      ),
      child: child,
    );
  }
}
