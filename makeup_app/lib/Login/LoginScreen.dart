import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import 'LoginAuthType.dart';
import 'EmailLogin.dart';
import 'EmailBtn.dart';
import 'PhoneLogin.dart';
import 'PhoneBtn.dart';
import 'GoogleLogin.dart';
import 'GoogleBtn.dart';
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
    _type = widget.type ?? LoginAuthType.Email;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget btn1;
    Widget btn2;
    switch(_type) {
      case LoginAuthType.Email: {
        child = EmailLogin(widget.hasAccount);
        btn1 = GoogleBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Google); });
        btn2 = PhoneBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Phone); });
        break;
      }
      case LoginAuthType.Phone: {
        child = PhoneLogin(widget.hasAccount);
        btn1 = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        btn2 = GoogleBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Google); });
        break;
      }
      case LoginAuthType.Google: {
        child = GoogleLogin(widget.hasAccount);
        btn1 = EmailBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Email); });
        btn2 = PhoneBtn(widget.hasAccount, onPressed: () { setType(LoginAuthType.Phone); });
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
            margin: EdgeInsets.all(25),
            child: child,
          ),
          btn1,
          btn2,
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
