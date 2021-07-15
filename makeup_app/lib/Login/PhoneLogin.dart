import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Look.dart';
import '../IO/loginIO.dart' as IO;
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import 'AccountScreen.dart';
import 'PhoneNumberTextInputFormatter.dart';

class PhoneLogin extends StatefulWidget {
  final bool hasAccount;

  PhoneLogin(this.hasAccount);

  @override
  PhoneLoginState createState() => PhoneLoginState();
}

class PhoneLoginState extends State<PhoneLogin> {
  late PhoneNumberTextInputFormatter _phoneNumberTextInputFormatter;
  String _countryCode = '1';
  String? _phoneNumber;

  String? _verificationId;
  String _smsCode = '';

  bool _hasSentMsg = false;

  String _error = '';

  late Map<int, Swatch?> _orgAccountSwatches;
  late Map<String, Look> _orgAccountLooks;

  @override
  void initState() {
    super.initState();
    _phoneNumberTextInputFormatter = PhoneNumberTextInputFormatter(_countryCode);
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
      child = getSMSCodeField(context);
      btn = globalWidgets.getFlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          AuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId ?? '', smsCode: _smsCode);
          globalWidgets.openLoadingDialog(context);
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
            widget.hasAccount ? 'Sign In' : 'Sign Up',
            style: theme.accentTextBold,
          ),
        ),
      );
    } else {
      child = getPhoneNumberFields(context);
      btn = globalWidgets.getFlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          verify(_countryCode, _phoneNumber ?? '');
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Send Message',
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
            _error = 'An error occurred. The phone number is invalid. Please try again or use a different method.';
            break;
          }
          default: {
            _error = 'An error occurred. ${e.message} Please try again or use a different method.';
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
              _error = 'The incorrect verification code was typed. Please try again.';
            });
            break;
          }
          default: {
            setState(() {
              _hasSentMsg = false;
              _error = 'An error occurred while signing in. Please try again or use a different method.';
            });
            break;
          }
        }
        return false;
      }
    }
    return true;
  }

  Widget getSMSCodeField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
            width: 2.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        autofocus: true,
        style: TextStyle(color: theme.primaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily, letterSpacing: 7.0),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        onChanged: (String val) {
          _smsCode = val;
        },
        decoration: InputDecoration(
          hintText: 'A verification code was sent to your phone.',
          hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.tertiaryTextSize, fontFamily: theme.fontFamily, letterSpacing: 0.78),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget getPhoneNumberFields(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
            width: 2.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(7)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextFormField(
              textAlign: TextAlign.left,
              initialValue: '+' + _countryCode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofocus: true,
              onChanged: (String val) {
                if(val[0] == '+') {
                  _countryCode = val.substring(1);
                } else {
                  _countryCode = val;
                }
                _phoneNumberTextInputFormatter.countryCode = _countryCode;
              },
              style: theme.primaryTextPrimary,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                CountryCodeTextInputFormatter(),
              ],
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: theme.accentColor,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: TextFormField(
              textAlign: TextAlign.left,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: theme.primaryTextPrimary,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                _phoneNumberTextInputFormatter,
              ],
              onChanged: (String val) {
                _phoneNumber = val;
              },
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: theme.accentColor,
              decoration: InputDecoration(
                hintText: 'Your Phone Number',
                hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

