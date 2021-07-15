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

class EmailLogin extends StatefulWidget {
  final bool hasAccount;

  EmailLogin(this.hasAccount);

  @override
  EmailLoginState createState() => EmailLoginState();
}

class EmailLoginState extends State<EmailLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email = '';
  String? _password = '';

  bool _autovalidate = false;
  bool _passwordVisible = false;
  
  bool _isResettingPassword = false;

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
    return Form(
      autovalidate: _autovalidate,
      key: _formKey,
      child: Column(
        children: <Widget>[
          getEmailField(context),
          const SizedBox(
            height: 12,
          ),
          if(!_isResettingPassword) getPasswordField(context),
          if(!_isResettingPassword) const SizedBox(
            height: 7,
          ),
          if(_error != '') Text(_error, style: theme.errorTextSecondary),
          if(_error != '') const SizedBox(
            height: 7,
          ),
          Container(
            width: 200,
            child: globalWidgets.getFlatButton(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              bgColor: theme.accentColor,
              onPressed: () {
                if(_formKey.currentState!.validate()) {
                  if(_isResettingPassword) {
                    IO.auth.sendPasswordResetEmail(email: _email ?? '').then(
                      (value) {
                        setState(() {
                          _isResettingPassword = false;
                          _error = 'An link to reset your password has been sent to your email. Please reset it and then attempt to login again.';
                          _autovalidate = false;
                        });
                      }
                    );
                  } else {
                    globalWidgets.openLoadingDialog(context);
                    signIn(widget.hasAccount, _email ?? '', _password ?? '').then(
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
                          setState(() { });
                        }
                      },
                    );
                  }
                } else {
                  setState(() { _autovalidate = true; });
                }
              },
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  (_isResettingPassword ? 'Reset Password' : (widget.hasAccount ? 'Login' : 'Sign Up')),
                  style: theme.accentTextBold,
                ),
              ),
            ),
          ),
          if(widget.hasAccount && !_isResettingPassword) getResetField(context),
        ],
      ),
    );
  }

  Future<bool> signIn(bool hasAccount, String email, String password) async {
    //check to make sure not signed in
    if(IO.auth.currentUser != null && IO.auth.currentUser!.email == null) {
      try {
        if(hasAccount) {
          await IO.auth.signInWithEmailAndPassword(email: email, password: password);
        } else {
          await IO.auth.createUserWithEmailAndPassword(email: email, password: password);
        }
        await IO.combineAccounts(context, _orgAccountSwatches, _orgAccountLooks);
      } on FirebaseAuthException catch (e) {
        switch(e.code) {
          case 'invalid-email': {
            _error = 'The email you gave is invalid.';
            break;
          }
          case 'user-disabled':
          case 'user-not-found': {
            _error = 'No account found for this email. Try signing up instead.';
            break;
          }
          case 'wrong-password': {
            _error = 'The password you entered is incorrect.';
            break;
          }
          case 'email-already-in-use': {
            _error = 'There is already an account with this email. Try signing in instead.';
            break;
          }
          case 'weak-password': {
            _error = 'The password you entered is too weak. Please try a different one.';
            break;
          }
          default: {
            _error = 'An error occurred while signing in. Please try again or use a different method.';
            break;
          }
        }
        return false;
      }
    }
    return true;
  }

  Widget getEmailField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: theme.primaryTextPrimary,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        onChanged: (String val) {
          _email = val;
        },
        validator: (String? val) {
          if(_email == null) {
            if(val != '') {
              _email = val ?? '';
            }
          }
          return emailValidate(val ?? '');
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          fillColor: theme.primaryColor,
          labelText: 'Email',
          labelStyle: theme.primaryTextPrimary,
          errorStyle: theme.errorTextSecondary,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.errorTextColor,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.errorTextColor,
              width: 2.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget getPasswordField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: widget.hasAccount ? TextInputAction.done : TextInputAction.next,
        style: theme.primaryTextPrimary,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        obscureText: !_passwordVisible,
        onChanged: (String val) {
          _password = val;
        },
        onEditingComplete: () {
          if(!widget.hasAccount) {
            do {
              FocusScope.of(context).nextFocus();
            } while(FocusScope.of(context).focusedChild!.context!.widget is! EditableText);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        validator: (String? val) {
          if(_password == null) {
            if(val != '') {
              _password = val ?? '';
            }
          }
          return passwordValidate(val ?? '');
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          fillColor: theme.primaryColor,
          labelText: 'Password',
          labelStyle: theme.primaryTextPrimary,
          errorStyle: theme.errorTextSecondary,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.errorTextColor,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.errorTextColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: theme.iconTextColor,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget getResetField(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isResettingPassword = true;
          _error = '';
          _autovalidate = false;
        });
      },
      child: Text(
        'Forgot password?',
        style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
      ),
    );
  }
  
  String? emailValidate(String? val) {
    if(val == null || val.length < 1) {
      return 'Email is required.';
    }
    if(!RegExp('^[a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$').hasMatch(val)) {
      return 'Email is not valid.';
    }
    return null;
  }

  String? passwordValidate(String? val) {
    if(_isResettingPassword) {
      return null;
    }
    if(val == null || val.length < 1) {
      return 'Password is required.';
    }
    if(val.length < 5) {
      return 'Password must be at least 5 characters.';
    }
    if(!RegExp('(?=.*?[a-z]).{1,}').hasMatch(val)) {
      return 'Password must contain a lowercase letter.';
    }
    if(!RegExp('(?=.*?[A-Z]).{1,}').hasMatch(val)) {
      return 'Password must contain an uppercase letter.';
    }
    if(!RegExp('(?=.*?[0-9]).{1,}').hasMatch(val)) {
      return 'Password must contain a number.';
    }
    return null;
  }
}