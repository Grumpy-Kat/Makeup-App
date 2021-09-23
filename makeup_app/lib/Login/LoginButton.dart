import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;
import '../navigation.dart' as navigation;
import 'LoginAuthType.dart';
import 'LoginScreen.dart';

class LoginButton extends StatelessWidget {
  final LoginAuthType type;

  LoginButton(this.type);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account?',
            style: theme.primaryTextSecondary,
          ),
          TextButton(
            onPressed: () {
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.LoginScreen,
                LoginScreen(true, type: type),
              );
            },
            child: Text(
              'Login here.',
              style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
