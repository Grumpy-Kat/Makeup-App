import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import 'LoginScreen.dart';

class SignOutButton extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  SignOutButton({ required this.horizontalPadding, required this.verticalPadding });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: horizontalPadding, right: verticalPadding, top: 3),
      child: OutlineButton(
        bgColor: theme.bgColor,
        outlineColor: theme.primaryColorDark,
        outlineWidth: 2.0,
        onPressed: () {
          globalWidgets.openLoadingDialog(context);
          IO.signOut().then(
            (value) {
              Navigator.pop(context);
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.LoginScreen,
                LoginScreen(true),
              );
            },
          );
        },
        child: Text(
          '${getString('signOut')}',
          style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
        ),
      ),
    );
  }
}
