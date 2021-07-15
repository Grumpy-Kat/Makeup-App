import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../IO/loginIO.dart' as IO;
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import 'LoginAuthType.dart';
import 'EmailLogin.dart';
import 'EmailBtn.dart';
import 'PhoneLogin.dart';
import 'PhoneBtn.dart';
import 'GoogleLogin.dart';
//import 'GoogleBtn.dart';
import 'LoginBtn.dart';
import 'SignUpBtn.dart';

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
    /*Widget btn1;
    Widget btn2;*/
    Widget btn;
    switch(_type) {
      case LoginAuthType.Email: {
        child = EmailLogin(widget.hasAccount);
        /*btn1 = GoogleBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Google); });
        btn2 = PhoneBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Phone); });*/
        btn = PhoneBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Phone); });
        break;
      }
      case LoginAuthType.Phone: {
        child = PhoneLogin(widget.hasAccount);
        /*btn1 = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        btn2 = GoogleBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Google); });*/
        btn = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        break;
      }
      case LoginAuthType.Google: {
        child = GoogleLogin(widget.hasAccount);
        /*btn1 = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        btn2 = PhoneBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Phone); });*/
        btn = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        break;
      }
    }
    return buildComplete(
      context,
      widget.hasAccount ? 'Login' : 'Sign Up',
      20,
      //back button
      leftBar: globalWidgets.getBackButton(() => navigation.pop(context, false)),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(25, 25, 25, 15),
            child: child,
          ),
          btn,
          widget.hasAccount ? SignUpBtn(_type) : LoginBtn(_type),
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
