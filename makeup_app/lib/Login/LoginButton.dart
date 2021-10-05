import 'package:flutter/material.dart';
import '../IO/localizationIO.dart';
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
            '${getString('loginButton_question')}',
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
              '${getString('loginButton_label')}',
              style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}