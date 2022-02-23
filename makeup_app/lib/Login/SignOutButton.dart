import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class SignOutButton extends StatelessWidget {
  final double leftPadding;
  final double rightPadding;

  SignOutButton({ required this.leftPadding, required this.rightPadding });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding, top: 3),
      child: OutlineButton(
        bgColor: theme.bgColor,
        outlineColor: theme.primaryColorDark,
        outlineWidth: 2.0,
        onPressed: () {
          globalWidgets.openLoadingDialog(context);
          IO.signOut().then(
            (val) {
              Navigator.pop(context);
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AllSwatchesScreen,
                routes.routes['/allSwatchesScreen']!(context),
              );
            }
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
