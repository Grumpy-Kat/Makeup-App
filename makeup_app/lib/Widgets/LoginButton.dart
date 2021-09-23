import 'package:flutter/material.dart';
import '../IO/loginIO.dart' as IO;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;

class LoginButton extends StatelessWidget {
  LoginButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints.tight(const Size.fromWidth(40)),
      icon: Icon(
        Icons.account_circle,
        size: 25,
        color: theme.iconTextColor,
      ),
      onPressed: () {
        if(IO.auth.currentUser != null && !IO.auth.currentUser!.isAnonymous) {
          navigation.pushReplacement(
            context,
            const Offset(1, 0),
            routes.ScreenRoutes.AccountScreen,
            routes.routes['/accountScreen']!(context),
          );
        } else {
          navigation.push(
            context,
            const Offset(1, 0),
            routes.ScreenRoutes.LoginScreen,
            routes.routes['/loginScreen']!(context),
          );
        }
      },
    );
  }
}
