import 'package:flutter/material.dart' hide FlatButton, OutlineButton, BackButton;
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/Screen.dart';
import '../Widgets/FlatButton.dart';
import '../Widgets/OutlineButton.dart';
import '../Widgets/BackButton.dart';
import '../IO/loginIO.dart' as IO;
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import 'LoginAuthType.dart';
import 'LoginScreen.dart';
import 'PhoneNumberField.dart';
import 'SMSCodeField.dart';
import 'PasswordField.dart';

class AccountScreen extends StatefulWidget {
  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with ScreenState {
  late LoginAuthType _type;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  bool _isChangingPassword = false;
  final GlobalKey _oldPasswordKey = GlobalKey();
  final GlobalKey _newPasswordKey = GlobalKey();

  bool _isChangingPhoneNumber = false;
  bool _hasSentCode = false;
  final GlobalKey _phoneNumberKey = GlobalKey();
  final GlobalKey _smsCodeKey = GlobalKey();
  String? _verificationId;

  String? _msg;
  String? _error;

  static const double horizPadding = 20;
  static const double vertPadding = 7;

  @override
  void initState() {
    super.initState();
    User? user = IO.auth.currentUser;
    if(user != null) {
      if(user.phoneNumber != null) {
        _type = LoginAuthType.Phone;
      } else if(user.email != null) {
        if (user.providerData[0].providerId == 'google.com') {
          _type = LoginAuthType.Google;
        } else {
          _type = LoginAuthType.Email;
        }
      } else {
        print('Neither email nor phone is set, which should not happen with the current login methods! LoginAuthType can not be properly set');
        _type = LoginAuthType.Email;
      }
    } else {
      print('User is null! LoginAuthType can not be properly set');
      _type = LoginAuthType.Email;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = IO.auth.currentUser;
    if(user != null) {
      List<Widget> widgets = [];
      switch(_type) {
        case LoginAuthType.Phone: {
          widgets = getPhoneFields(context, user);
          break;
        }
        case LoginAuthType.Email: {
          widgets = getEmailFields(context, user);
          break;
        }
        case LoginAuthType.Google: {
          widgets = getGoogleFields(context, user);
          break;
        }
      }
      return buildComplete(
        context,
        'Account',
        21,
        //back button
        leftBar: BackButton(onPressed: () => navigation.pop(context, false)),
        body: Form(
          autovalidate: _autovalidate,
          key: _formKey,
          child: Column(
            children: <Widget>[
              for(int i = 0; i < widgets.length; i++) widgets[i],
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: horizPadding, right: vertPadding, top: 3),
                child: OutlineButton(
                  bgColor: theme.bgColor,
                  outlineColor: theme.primaryColorDark,
                  outlineWidth: 2.0,
                  onPressed: () {
                    IO.signOut().then(
                      (value) {
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
                    'Sign Out',
                    style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  List<Widget> getPhoneFields(BuildContext context, User user) {
    return <Widget>[
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, top: vertPadding),
        child: Row(
          children: <Widget>[
            Text(
              'Phone Number: ',
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: TextFormField(
                scrollPadding: EdgeInsets.zero,
                keyboardType: TextInputType.phone,
                style: theme.primaryTextPrimary,
                controller: TextEditingController()..text = user.phoneNumber ?? '',
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.left,
                enabled: false,
                decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      if(_isChangingPhoneNumber && !_hasSentCode) PhoneNumberField(key: _phoneNumberKey),
      if(_isChangingPhoneNumber && _hasSentCode) SMSCodeField(key: _smsCodeKey),
      if(_isChangingPhoneNumber) const SizedBox(
        height: vertPadding,
      ),
      if(_isChangingPhoneNumber && !_hasSentCode) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: FlatButton(
          bgColor: theme.accentColor,
          onPressed: () async {
            globalWidgets.openLoadingDialog(context);

            String? countryCode;
            if(_phoneNumberKey.currentState != null) {
              countryCode = (_phoneNumberKey.currentState as PhoneNumberFieldState).countryCode;
            }

            String? phoneNumber;
            if(_phoneNumberKey.currentState != null) {
              phoneNumber = (_phoneNumberKey.currentState as PhoneNumberFieldState).phoneNumber;
            }

            await IO.auth.verifyPhoneNumber(
              phoneNumber: '+$countryCode$phoneNumber',
              timeout: const Duration(milliseconds: 5000),
              verificationCompleted: (PhoneAuthCredential credential) {
                user.updatePhoneNumber(credential).then(
                  (_) {
                    setState(() {
                      _msg = 'Your phone number has been successfully changed.';
                      _error = null;
                      _isChangingPhoneNumber = false;
                    });
                    Navigator.pop(context);
                  }
                ).catchError(
                  (e) {
                    setState(() {
                      _error = 'There was an issue changing your phone number.';
                      print('${e.code} ${e.message}');
                    });
                    Navigator.pop(context);
                  }
                );
              },
              verificationFailed: (FirebaseAuthException e) {
                _hasSentCode = false;
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
                  _hasSentCode = true;
                  _error = null;
                  _verificationId = verificationId;
                  Navigator.of(context).pop();
                  setState(() {});
                });
              },
              codeAutoRetrievalTimeout: (String verificationId) {
                _verificationId = verificationId;
              },
            );
          },
          child: Text(
            'Send Message',
            style: theme.accentTextBold,
          ),
        ),
      ),
      if(_isChangingPhoneNumber && _hasSentCode) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
        child: FlatButton(
          bgColor: theme.accentColor,
          onPressed: () {
            globalWidgets.openLoadingDialog(context);

            String? smsCode;
            if(_smsCodeKey.currentState != null) {
              smsCode = (_smsCodeKey.currentState as SMSCodeFieldState).smsCode;
            }
            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId ?? '', smsCode: smsCode ?? '') as PhoneAuthCredential;

            user.updatePhoneNumber(credential).then(
              (_) {
                setState(() {
                  _msg = 'Your phone number has been successfully changed.';
                  _error = null;
                  _isChangingPhoneNumber = false;
                });
                Navigator.pop(context);
              }
            ).catchError(
              (e) {
                setState(() {
                  if(e.code == 'invalid-verification-code') {
                    _error = 'The incorrect verification code was typed. Please try again.';
                  } else {
                    _error = 'There was an issue changing your phone number.';
                  }
                  _hasSentCode = false;
                  print('${e.code} ${e.message}');
                });
                Navigator.pop(context);
              }
            );
          },
          child: Text(
            'Update Phone Number',
            style: theme.accentTextBold,
          ),
        ),
      ),
      if(!_isChangingPhoneNumber) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: OutlineButton(
          bgColor: theme.bgColor,
          outlineColor: theme.primaryColorDark,
          outlineWidth: 2.0,
          onPressed: () {
            setState(() {
              _msg = null;
              _error = null;
              _isChangingPhoneNumber = true;
            });
          },
          child: Text(
            'Change Phone Number',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
          ),
        ),
      ),
      if(_msg != null) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: Text(
          _msg ?? '',
          style: theme.primaryTextSecondary,
          textAlign: TextAlign.left,
        ),
      ),
      if(_error != null) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: Text(
          _error ?? '',
          style: theme.errorTextSecondary,
          textAlign: TextAlign.left,
        ),
      ),
    ];
  }

  List<Widget> getEmailFields(BuildContext context, User user) {
    return <Widget>[
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, top: vertPadding),
        child: Row(
          children: <Widget>[
            Text(
              'Email: ',
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: TextFormField(
                scrollPadding: EdgeInsets.zero,
                keyboardType: TextInputType.emailAddress,
                style: theme.primaryTextPrimary,
                initialValue: user.email,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.left,
                enabled: false,
                decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      //do not validate if already has password
      //password might have been changed through firebase or another source, where the password was not properly validated
      if(_isChangingPassword) PasswordField(shouldValidate: false, key: _oldPasswordKey, text: 'Old Password'),
      if(_isChangingPassword) const SizedBox(
        height: 10,
      ),
      if(_isChangingPassword) PasswordField(shouldValidate: true, key: _newPasswordKey, text: 'New Password'),
      if(_isChangingPassword) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
        child: FlatButton(
          bgColor: theme.accentColor,
          onPressed: () {
            if(_formKey.currentState!.validate()) {
              globalWidgets.openLoadingDialog(context);

              String? oldPassword;
              if(_oldPasswordKey.currentState != null) {
                oldPassword = (_oldPasswordKey.currentState as PasswordFieldState).password;
              }

              String? newPassword;
              if(_newPasswordKey.currentState != null) {
                newPassword = (_newPasswordKey.currentState as PasswordFieldState).password;
              }

              IO.auth.signInWithEmailAndPassword(email: user.email ?? '', password: oldPassword ?? '').then(
                (_) {
                  user.updatePassword(newPassword ?? '').then(
                    (_) {
                      setState(() {
                        _msg = 'Your password has been successfully changed.';
                        _error = null;
                        _isChangingPassword = false;
                        _autovalidate = false;
                      });
                      Navigator.pop(context);
                    }
                  ).catchError(
                    (e) {
                      setState(() {
                        _error = 'There was an issue changing your password.';
                        print('${e.code} ${e.message}');
                      });
                      Navigator.pop(context);
                    }
                  );
                }
              ).catchError(
                (e) {
                  setState(() {
                    if(e.code == 'wrong-password') {
                      _error = 'The old password you entered is incorrect.';
                    } else {
                      _error = 'There was an issue changing your password.';
                    }
                    print('${e.code} ${e.message}');
                  });
                  Navigator.pop(context);
                }
              );
            } else {
              setState(() { _autovalidate = true; });
            }
          },
          child: Text(
            'Reset Password',
            style: theme.accentTextBold,
          ),
        ),
      ),
      if(!_isChangingPassword) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: OutlineButton(
          bgColor: theme.bgColor,
          outlineColor: theme.primaryColorDark,
          outlineWidth: 2.0,
          onPressed: () {
            setState(() {
              _msg = null;
              _error = null;
              _isChangingPassword = true;
              _autovalidate = false;
            });
          },
          child: Text(
            'Change Password',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
          ),
        ),
      ),
      if(_msg != null) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: Text(
          _msg ?? '',
          style: theme.primaryTextSecondary,
          textAlign: TextAlign.left,
        ),
      ),
      if(_error != null) Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: vertPadding),
        child: Text(
          _error ?? '',
          style: theme.errorTextSecondary,
          textAlign: TextAlign.left,
        ),
      ),
    ];
  }

  List<Widget> getGoogleFields(BuildContext context, User user) {
    return <Widget>[
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, top: 14),
        child: Text(
          'Signed in through Google.',
          style: theme.primaryTextPrimary,
          textAlign: TextAlign.left,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: horizPadding, right: horizPadding, bottom: 3),
        child: Row(
          children: <Widget>[
            Text(
              'Email: ',
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: TextFormField(
                scrollPadding: EdgeInsets.zero,
                keyboardType: TextInputType.emailAddress,
                style: theme.primaryTextPrimary,
                initialValue: user.email,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.left,
                enabled: false,
                decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}