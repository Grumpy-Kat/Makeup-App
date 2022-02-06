import 'package:flutter/material.dart' hide FlatButton;
import 'package:firebase_auth/firebase_auth.dart';
import '../Data/Swatch.dart';
import '../Data/Look.dart';
import '../Widgets/FlatButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import 'AccountScreen.dart';
import 'PhoneNumberField.dart';
import 'SMSCodeField.dart';

class PhoneLogin extends StatefulWidget {
  final bool hasAccount;

  PhoneLogin(this.hasAccount);

  @override
  PhoneLoginState createState() => PhoneLoginState();
}

class PhoneLoginState extends State<PhoneLogin> {
  final GlobalKey _phoneNumberKey = GlobalKey();
  final GlobalKey _smsCodeKey = GlobalKey();

  String? _verificationId;

  bool _hasSentMsg = false;

  String _error = '';

  late Map<int, Swatch?> _orgAccountSwatches;
  late Map<String, Look> _orgAccountLooks;

  @override
  void initState() {
    super.initState();
    //save original swatches for later use
    if(allSwatchesIO.swatches == null || allSwatchesIO.hasSaveChanged) {
      allSwatchesIO.loadFormatted().then(
        (value) {
          _orgAccountSwatches = allSwatchesIO.swatches!;
        }
      );
    } else {
      _orgAccountSwatches = allSwatchesIO.swatches!;
    }
    //save original looks for later use
    if(savedLooksIO.looks == null || savedLooksIO.hasSaveChanged) {
      savedLooksIO.loadFormatted().then(
        (value) {
          _orgAccountLooks = savedLooksIO.looks!;
        }
      );
    } else {
      _orgAccountLooks = savedLooksIO.looks!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget btn;
    if(_hasSentMsg) {
      child = SMSCodeField(key: _smsCodeKey);
      btn = FlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          globalWidgets.openLoadingDialog(context);

          String? smsCode;
          if(_smsCodeKey.currentState != null) {
            smsCode = (_smsCodeKey.currentState as SMSCodeFieldState).smsCode;
          }
          AuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId ?? '', smsCode: smsCode ?? '');

          signIn(credential).then(
            (bool value) {
              Navigator.of(context).pop();
              if(value) {
                navigation.pushReplacement(
                  context,
                  const Offset(1, 0),
                  routes.ScreenRoutes.AccountScreen,
                  AccountScreen(),
                );
              }
            },
          );
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.hasAccount ? getString('signIn') : getString('signUp'),
            style: theme.accentTextBold,
          ),
        ),
      );
    } else {
      child = PhoneNumberField(key: _phoneNumberKey);
      btn = FlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          String? countryCode;
          if(_phoneNumberKey.currentState != null) {
            countryCode = (_phoneNumberKey.currentState as PhoneNumberFieldState).countryCode;
          }

          String? phoneNumber;
          if(_phoneNumberKey.currentState != null) {
            phoneNumber = (_phoneNumberKey.currentState as PhoneNumberFieldState).phoneNumber;
          }

          verify(countryCode ?? '1', phoneNumber ?? '');
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '${getString('phoneLogin_send')}',
            style: theme.accentTextBold,
          ),
        ),
      );
    }
    return Column(
      children: <Widget>[
        child,
        const SizedBox(
          height: 7,
        ),
        if(_error != '') Text(_error, style: theme.errorTextSecondary),
        Container(
          width: 200,
          child: btn,
        ),
      ],
    );
  }

  Future<void> verify(String countryCode, String phoneNumber) async {
    globalWidgets.openLoadingDialog(context);
    await IO.auth.verifyPhoneNumber(
      phoneNumber: '+$countryCode$phoneNumber',
      timeout: const Duration(milliseconds: 5000),
      verificationCompleted: (PhoneAuthCredential credential) {
        signIn(credential).then(
          (bool value) {
            Navigator.of(context).pop();
            if(value) {
              navigation.pushReplacement(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.AccountScreen,
                AccountScreen(),
              );
            }
          },
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        _hasSentMsg = false;
        switch(e.code) {
          case 'invalid-phone-number': {
            _error = getString('phoneLogin_warning0');
            break;
          }
          default: {
            print(e);
            _error = getString('phoneLogin_warning2');
            break;
          }
        }
        Navigator.of(context).pop();
        setState(() {});
      },
      codeSent: (String verificationId, [int? forceResendingToken]) {
        setState(() {
          _hasSentMsg = true;
          _error = '';
          _verificationId = verificationId;
          Navigator.of(context).pop();
          setState(() {});
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<bool> signIn(AuthCredential credential) async {
    //check to make sure not signed in
    if(IO.auth.currentUser != null && IO.auth.currentUser!.phoneNumber == null) {
      try {
        await IO.auth.signInWithCredential(credential);
        await IO.combineAccounts(context, _orgAccountSwatches, _orgAccountLooks);
      } on FirebaseAuthException catch (e) {
        switch(e.code) {
          case 'invalid-verification-code': {
            setState(() {
              _hasSentMsg = false;
              _error = getString('phoneLogin_warning1');
            });
            break;
          }
          default: {
            setState(() {
              _hasSentMsg = false;
              _error = getString('phoneLogin_warning2');
            });
            break;
          }
        }
        return false;
      }
    }
    return true;
  }
}

