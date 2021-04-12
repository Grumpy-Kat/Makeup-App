import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart' as theme;

class EmailLogin extends StatefulWidget {
  final bool hasAccount;

  EmailLogin(this.hasAccount);

  @override
  EmailLoginState createState() => EmailLoginState();
}

class EmailLoginState extends State<EmailLogin> {
  String? _email;
  String? _password;
  String? _confirm;

  bool _passwordVisible = false;
  bool _confirmVisible = false;

  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        getEmailField(context),
        const SizedBox(
          height: 12,
        ),
        getPasswordField(context),
        const SizedBox(
          height: 12,
        ),
        if(!widget.hasAccount) getConfirmField(context),
        if(!widget.hasAccount) const SizedBox(
          height: 7,
        ),
        TextButton(
          onPressed: () {
            if(emailValidate(_email) == null && passwordValidate(_password) == null && confirmValidate(_confirm) == null) {
              //TODO: login or sign up
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            primary: theme.accentColor,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(2)),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.hasAccount ? 'Login' : 'Sign Up',
              style: theme.accentTextBold,
            ),
          ),
        ),
        if(_error != '') Text(_error, style: theme.errorText),
      ],
    );
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
        autovalidateMode: AutovalidateMode.always,
        validator: (String? val) {
          if(_email == null) {
            if(val != '') {
              _email = val;
            } else {
              return null;
            }
          }
          return emailValidate(val);
        },
        decoration: InputDecoration(
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
        autovalidateMode: AutovalidateMode.always,
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
              _password = val;
            } else {
              return null;
            }
          }
          return passwordValidate(val);
        },
        decoration: InputDecoration(
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

  Widget getConfirmField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        style: theme.primaryTextPrimary,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        obscureText: !_confirmVisible,
        onChanged: (String val) {
          _confirm = val;
        },
        autovalidateMode: AutovalidateMode.always,
        validator: (String? val) {
          if(_confirm == null) {
            if(val != '') {
              _confirm = val;
            } else {
              return null;
            }
          }
          return confirmValidate(val);
        },
        decoration: InputDecoration(
          fillColor: theme.primaryColor,
          labelText: 'Confirm Password',
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
              _confirmVisible ? Icons.visibility : Icons.visibility_off,
              color: theme.iconTextColor,
            ),
            onPressed: () {
              setState(() {
                _confirmVisible = !_confirmVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  String? emailValidate(String? val) {
    if(val!.length < 1) {
      return 'Email is required.';
    }
    if(!RegExp('^[a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$').hasMatch(val)) {
      return 'Email is not valid.';
    }
    return null;
  }

  String? passwordValidate(String? val) {
    if(val!.length < 1) {
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

  String? confirmValidate(String? val) {
    if(val!.length < 1) {
      return 'Password confirmation is required.';
    }
    if(val != _password) {
      return 'Confirmation does not match password.';
    }
    return null;
  }
}