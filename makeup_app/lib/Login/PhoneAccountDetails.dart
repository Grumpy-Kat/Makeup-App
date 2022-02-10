import 'package:flutter/material.dart' hide FlatButton, OutlineButton;
import 'package:firebase_auth/firebase_auth.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../Widgets/FlatButton.dart';
import '../Widgets/OutlineButton.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import 'PhoneNumberField.dart';
import 'SMSCodeField.dart';

class PhoneAccountDetails extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;

  final User user;

  final Widget buttons;

  PhoneAccountDetails({ required this.horizontalPadding, required this.verticalPadding, required this.user, required this.buttons });

  @override
  PhoneAccountDetailsState createState() => PhoneAccountDetailsState();
}

class PhoneAccountDetailsState extends State<PhoneAccountDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  bool _isChangingPhoneNumber = false;
  bool _hasSentCode = false;
  final GlobalKey _phoneNumberKey = GlobalKey();
  final GlobalKey _smsCodeKey = GlobalKey();
  String? _verificationId;

  String? _msg;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: _autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: widget.horizontalPadding, right: widget.horizontalPadding, top: widget.verticalPadding),
            child: Row(
              children: <Widget>[
                Text(
                  '${getString('account_phone')}: ',
                  style: theme.primaryTextPrimary,
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  child: TextFormField(
                    scrollPadding: EdgeInsets.zero,
                    keyboardType: TextInputType.phone,
                    style: theme.primaryTextPrimary,
                    controller: TextEditingController()..text = widget.user.phoneNumber ?? '',
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

          if(_isChangingPhoneNumber && !_hasSentCode) PhoneNumberField(
            key: _phoneNumberKey,
          ),

          if(_isChangingPhoneNumber && _hasSentCode) SMSCodeField(
            key: _smsCodeKey,
          ),

          if(_isChangingPhoneNumber) SizedBox(
            height: widget.verticalPadding,
          ),

          if(_isChangingPhoneNumber && !_hasSentCode) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: widget.horizontalPadding, right: widget.horizontalPadding, bottom: widget.verticalPadding),
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
                    widget.user.updatePhoneNumber(credential).then(
                      (_) {
                        setState(() {
                          _msg = getString('account_phoneSuccess');
                          _error = null;
                          _isChangingPhoneNumber = false;
                        });

                        Navigator.pop(context);
                      }
                    ).catchError(
                      (e) {
                        setState(() {
                          _error = getString('account_phoneWarning2');
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
                        _error = getString('account_phoneWarning0');
                        break;
                      }
                      default: {
                        _error = getString('account_phoneWarning2');
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
                '${getString('account_phoneSend')}',
                style: theme.accentTextBold,
              ),
            ),
          ),

          if(_isChangingPhoneNumber && _hasSentCode) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
            child: FlatButton(
              bgColor: theme.accentColor,
              onPressed: () {
                globalWidgets.openLoadingDialog(context);

                String? smsCode;
                if(_smsCodeKey.currentState != null) {
                  smsCode = (_smsCodeKey.currentState as SMSCodeFieldState).smsCode;
                }
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId ?? '', smsCode: smsCode ?? '');

                widget.user.updatePhoneNumber(credential).then(
                  (_) {
                    setState(() {
                      _msg = getString('account_phoneSuccess');
                      _error = null;
                      _isChangingPhoneNumber = false;
                    });

                    Navigator.pop(context);
                  }
                ).catchError(
                  (e) {
                    setState(() {
                      if(e.code == 'invalid-verification-code') {
                        _error = getString('account_phoneWarning1');
                      } else {
                        _error = getString('account_phoneWarning2');
                      }

                      _hasSentCode = false;

                      print('${e.code} ${e.message}');
                    });

                    Navigator.pop(context);
                  }
                );
              },
              child: Text(
                '${getString('account_phoneChange')}',
                style: theme.accentTextBold,
              ),
            ),
          ),

          if(!_isChangingPhoneNumber) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: widget.horizontalPadding, right: widget.horizontalPadding, bottom: widget.verticalPadding),
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
                '${getString('account_phoneChange')}',
                style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
              ),
            ),
          ),

          if(_msg != null) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: widget.horizontalPadding, right: widget.horizontalPadding, bottom: widget.verticalPadding),
            child: Text(
              _msg ?? '',
              style: theme.primaryTextSecondary,
              textAlign: TextAlign.left,
            ),
          ),

          if(_error != null) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: widget.horizontalPadding, right: widget.horizontalPadding, bottom: widget.verticalPadding),
            child: Text(
              _error ?? '',
              style: theme.errorTextSecondary,
              textAlign: TextAlign.left,
            ),
          ),

          widget.buttons,
        ],
      ),
    );
  }
}
