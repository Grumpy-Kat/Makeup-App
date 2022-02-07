import 'package:flutter/material.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;

class PasswordField extends StatefulWidget {
  final bool shouldValidate;
  final String text;
  final bool isNewPassword;

  PasswordField({ Key? key, required this.shouldValidate, required this.text, required this.isNewPassword }) : super(key: key);

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  String? password = '';

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: TextFormField(
        textAlign: TextAlign.left,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: widget.isNewPassword ? [AutofillHints.password] : [AutofillHints.newPassword],
        textInputAction: TextInputAction.done,
        style: theme.primaryTextPrimary,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        obscureText: !_passwordVisible,
        onChanged: (String val) {
          password = val;
        },
        validator: (String? val) {
          if(password == null) {
            if(val != '') {
              password = val ?? '';
            }
          }
          return passwordValidate(val ?? '');
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          fillColor: theme.primaryColor,
          labelText: widget.text,
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

  String? passwordValidate(String? val) {
    if(!widget.shouldValidate) {
      return null;
    }
    if(val == null || val.length < 1) {
      return getString('passwordField_warning0');
    }
    if(val.length < 5) {
      return getString('passwordField_warning1');
    }
    if(!RegExp('(?=.*?[a-z]).{1,}').hasMatch(val)) {
      return getString('passwordField_warning2');
    }
    if(!RegExp('(?=.*?[A-Z]).{1,}').hasMatch(val)) {
      return getString('passwordField_warning3');
    }
    if(!RegExp('(?=.*?[0-9]).{1,}').hasMatch(val)) {
      return getString('passwordField_warning4');
    }
    return null;
  }
}