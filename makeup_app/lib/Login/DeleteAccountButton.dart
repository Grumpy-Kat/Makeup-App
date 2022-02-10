import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../IO/loginIO.dart' as IO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import 'LoginScreen.dart';

class DeleteAccountButton extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  DeleteAccountButton({ required this.horizontalPadding, required this.verticalPadding });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: horizontalPadding, right: verticalPadding, top: 3),
      child: OutlineButton(
        bgColor: theme.bgColor,
        outlineColor: theme.errorTextColor,
        outlineWidth: 2.0,
        onPressed: () {
          globalWidgets.openLoadingDialog(context);
          IO.deleteAccount().then(
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
          'Delete Account',
          style: TextStyle(color: theme.errorTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
        ),
      ),
    );
  }
}
