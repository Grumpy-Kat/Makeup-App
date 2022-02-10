import 'package:flutter/material.dart' hide FlatButton, OutlineButton;
import 'package:firebase_auth/firebase_auth.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../Widgets/FlatButton.dart';
import '../Widgets/OutlineButton.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import 'PasswordField.dart';

class EmailAccountDetails extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;

  final User user;

  final Widget buttons;

  EmailAccountDetails({ required this.horizontalPadding, required this.verticalPadding, required this.user, required this.buttons });

  @override
  EmailAccountDetailsState createState() => EmailAccountDetailsState();
}

class EmailAccountDetailsState extends State<EmailAccountDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  bool _isChangingPassword = false;
  final GlobalKey _oldPasswordKey = GlobalKey();
  final GlobalKey _newPasswordKey = GlobalKey();

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
                  '${getString('account_email')}: ',
                  style: theme.primaryTextPrimary,
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  child: TextFormField(
                    scrollPadding: EdgeInsets.zero,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.primaryTextPrimary,
                    initialValue: widget.user.email,
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

          // Do not validate if already has password
          // Password might have been changed through firebase or another source, where the password was not properly validated
          if(_isChangingPassword) PasswordField(
            key: _oldPasswordKey,
            shouldValidate: false,
            text: getString('account_passwordOld'),
            isNewPassword: true,
          ),

          if(_isChangingPassword) const SizedBox(
            height: 10,
          ),

          if(_isChangingPassword) PasswordField(
            key: _newPasswordKey,
            shouldValidate: true,
            text: getString('account_passwordNew'),
            isNewPassword: false,
          ),

          if(_isChangingPassword) Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
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

                  IO.auth.signInWithEmailAndPassword(email: widget.user.email ?? '', password: oldPassword ?? '').then(
                    (_) {
                      widget.user.updatePassword(newPassword ?? '').then(
                        (_) {
                          setState(() {
                            _msg = getString('account_passwordSuccess');
                            _error = null;
                            _isChangingPassword = false;
                            _autovalidate = false;
                          });
                          Navigator.pop(context);
                        }
                      ).catchError(
                        (e) {
                          setState(() {
                            _error = getString('account_passwordWarning1');
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
                          _error = getString('account_passwordWarning0');
                        } else {
                          _error = getString('account_passwordWarning1');
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
                '${getString('account_passwordChange')}',
                style: theme.accentTextBold,
              ),
            ),
          ),

          if(!_isChangingPassword) Container(
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
                  _isChangingPassword = true;
                  _autovalidate = false;
                });
              },
              child: Text(
                '${getString('account_passwordChange')}',
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
