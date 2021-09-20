import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';

class OutlineButton extends StatelessWidget {
  final OnVoidAction? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final Color? bgColor;
  final Color? outlineColor;
  final double? outlineWidth;
  final Color? splashColor;

  OutlineButton({ Key? key, required this.onPressed, required this.child, this.padding, this.bgColor, this.outlineColor, this.outlineWidth, this.splashColor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: bgColor ?? Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(2)),
        ),
      ).copyWith(
        side: MaterialStateProperty.resolveWith<BorderSide?>(
          (Set<MaterialState> states) {
            if(states.contains(MaterialState.pressed)) {
              return BorderSide(
                color: outlineColor ?? theme.primaryColorDark,
                width: outlineWidth ?? 1,
              );
            }
            return null;
          },
        ),
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
