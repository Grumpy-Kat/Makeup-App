import 'package:GlamKit/Login/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;
import '../navigation.dart' as navigation;
import 'LoginAuthType.dart';
import 'LoginScreen.dart';

class SignUpButton extends StatelessWidget {
  final LoginAuthType type;

  SignUpButton(this.type);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${getString('signUpButton_question')}',
            style: theme.primaryTextSecondary,
          ),
          TextButton(
            onPressed: () {
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.LoginScreen,
                LoginScreen(false, type: type),
              );
            },
            child: Text(
              '${getString('signUpButton_label')}',
              style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
