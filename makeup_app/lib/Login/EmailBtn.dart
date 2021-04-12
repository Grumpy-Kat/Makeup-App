import 'package:flutter/material.dart';
import '../types.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class EmailBtn extends StatelessWidget {
  final bool hasAccount;
  final OnVoidAction? onPressed;

  EmailBtn(this.hasAccount, { this.onPressed });

  @override
  Widget build(BuildContext context) {
    return globalWidgets.getOutlineButton(
      bgColor: theme.bgColor,
      outlineColor: theme.primaryColorDark,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.email,
            size: theme.secondaryIconSize,
          ),
          Container(
            width: 230,
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              hasAccount ? 'Login with email' : 'Sign up with email',
              style: theme.primaryTextSecondary,
            ),
          )
        ],
      ),
    );
  }
}
