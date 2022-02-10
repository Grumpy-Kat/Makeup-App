import 'package:flutter/material.dart' hide BackButton;
import '../Screens/Screen.dart';
import '../Widgets/BackButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import 'LoginAuthType.dart';
import 'EmailLogin.dart';
import 'EmailButton.dart';
import 'PhoneLogin.dart';
import 'GoogleLogin.dart';
import 'GoogleButton.dart';
import 'LoginButton.dart';
import 'SignUpButton.dart';

class LoginScreen extends StatefulWidget {
  final LoginAuthType? type;
  final bool hasAccount;

  LoginScreen(this.hasAccount, { this.type });

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with ScreenState {
  late LoginAuthType _type;

  @override
  void initState() {
    super.initState();
    if(IO.auth.currentUser != null && !IO.auth.currentUser!.isAnonymous) {
      navigation.pushReplacement(
        context,
        const Offset(1, 0),
        routes.ScreenRoutes.AccountScreen,
        routes.routes['/accountScreen']!(context),
      );
    }
    _type = widget.type ?? LoginAuthType.Email;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget btn;
    switch(_type) {
      case LoginAuthType.Email: {
        child = EmailLogin(widget.hasAccount);
        btn = GoogleButton(widget.hasAccount, onPressed: () { setType(LoginAuthType.Google); });
        break;
      }
      case LoginAuthType.Phone: {
        child = PhoneLogin(widget.hasAccount);
        btn = EmailButton(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        break;
      }
      case LoginAuthType.Google: {
        child = GoogleLogin(widget.hasAccount);
        btn = EmailButton(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        break;
      }
    }

    return buildComplete(
      context,
      widget.hasAccount ? getString('login') : getString('signUp'),
      20,
      //back button
      leftBar: BackButton(onPressed: () => navigation.pop(context, false)),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(25, 25, 25, 15),
            child: child,
          ),
          btn,
          widget.hasAccount ? SignUpButton(_type) : LoginButton(_type),
        ],
      ),
    );
  }

  void setType(LoginAuthType type) {
    setState(() {
      _type = type;
    });
  }
}
