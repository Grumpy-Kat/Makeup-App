import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../types.dart';
import '../theme.dart' as theme;

class GoogleButton extends StatelessWidget {
  final bool hasAccount;
  final OnVoidAction? onPressed;

  GoogleButton(this.hasAccount, { this.onPressed });

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
          Image(
            image: AssetImage('imgs/google_logo.png'),
            width: theme.secondaryIconSize,
            height: theme.secondaryIconSize,
          ),
          Container(
            width: 230,
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              hasAccount ? 'Login with Google' : 'Sign up with Google',
              style: theme.primaryTextSecondary,
            ),
          )
        ],
      ),
    );
  }
}
