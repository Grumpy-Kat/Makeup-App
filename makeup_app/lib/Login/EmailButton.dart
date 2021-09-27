import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../IO/localizationIO.dart';
import '../types.dart';
import '../theme.dart' as theme;

class EmailButton extends StatelessWidget {
  final bool hasAccount;
  final OnVoidAction? onPressed;

  EmailButton(this.hasAccount, { this.onPressed });

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      bgColor: theme.bgColor,
      outlineColor: theme.primaryColorDark,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.email,
            color: theme.iconTextColor,
            size: theme.secondaryIconSize,
          ),
          Container(
            width: 230,
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              hasAccount ? getString('emailButton_login') : getString('emailButton_signUp'),
              style: theme.primaryTextSecondary,
            ),
          )
        ],
      ),
    );
  }
}
