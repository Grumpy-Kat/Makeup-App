import 'package:flutter/material.dart' hide FlatButton;
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';
import '../Widgets/FlatButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../IO/combineAccountsLoginIO.dart' as IO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import 'AccountScreen.dart';
import 'Login.dart';

class GoogleLogin extends StatefulWidget {
  final bool hasAccount;

  GoogleLogin(this.hasAccount);

  @override
  GoogleLoginState createState() => GoogleLoginState();
}

class GoogleLoginState extends State<GoogleLogin> with LoginState {
  bool _isSigningIn = false;

  String _error = '';

  @override
  void initState() {
    super.initState();

    preserveSaveData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(),

        if(_error != '') Text(_error, style: theme.errorTextSecondary),

        if(_error != '') const SizedBox(
          height: 7,
        ),

        Container(
          width: 200,
          child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            bgColor: theme.accentColor,
            onPressed: () {
              if(!_isSigningIn) {
                globalWidgets.openLoadingDialog(context);
                signIn().then(
                  (bool value) {
                    Navigator.of(context).pop();
                    if(value) {
                      navigation.pushReplacement(
                        context,
                        const Offset(1, 0),
                        routes.ScreenRoutes.AccountScreen,
                        AccountScreen(),
                      );
                    } else {
                      setState(() {});
                    }
                  },
                );
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${getString('signIn')}',
                style: theme.accentTextBold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> signIn() async {
    _isSigningIn = true;
    GoogleSignInAuthentication googleAuth;
    try {
      GoogleSignInAccount? user = (await GoogleSignIn().signIn());
      googleAuth = await user.authentication;
    } catch(e) {
      print('credential issue $e');
      print('google sign in error');
      print(e);
      setState(() {
        _error = 'An error occurred while signing in. Please try again or use a different method.';
      });
      return false;
    }
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await IO.auth.signInWithCredential(credential);
      await IO.combineAccounts(context, orgAccount);
    } on FirebaseAuthException catch (e) {
      print('${e.code} ${e.message}');
      print('Firebase error');
      setState(() {
        _error = 'An error occurred while signing in. Please try again or use a different method.';
      });
      _isSigningIn = false;
      return false;
    }
    _isSigningIn = false;
    return true;
  }
}
