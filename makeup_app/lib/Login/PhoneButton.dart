import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../types.dart';
import '../theme.dart' as theme;

class PhoneButton extends StatelessWidget {
  final bool hasAccount;
  final OnVoidAction? onPressed;

  PhoneButton(this.hasAccount, { this.onPressed });

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
            Icons.phone,
            color: theme.iconTextColor,
            size: theme.secondaryIconSize,
          ),
          Container(
            width: 230,
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              hasAccount ? 'Login with phone number' : 'Sign up with phone number',
              style: theme.primaryTextSecondary,
            ),
          )
        ],
      ),
    );
  }
}
