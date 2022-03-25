import 'package:flutter/material.dart' hide OutlineButton;
import '../Widgets/OutlineButton.dart';
import '../IO/loginIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class DeleteAccountButton extends StatelessWidget {
  final double leftPadding;
  final double rightPadding;

  DeleteAccountButton({ required this.leftPadding, required this.rightPadding });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding, top: 3),
      child: OutlineButton(
        bgColor: theme.bgColor,
        outlineColor: theme.errorTextColor,
        outlineWidth: 2.0,
        onPressed: () {
          globalWidgets.openTwoButtonDialog(
            context,
            getString('settings_default_resetQuestion'),
            () {
              globalWidgets.openLoadingDialog(context);
              IO.deleteAccount().then(
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
            () { },
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
