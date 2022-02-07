import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';

class StringFormField extends StatelessWidget {
  final String? label;
  final String? value;

  final String? error;
  final bool showErrorText;

  final OnStringAction? onChanged;
  final OnStringAction? onSubmitted;

  StringFormField({ this.label, this.value, this. error, this.showErrorText = false, this.onChanged, this.onSubmitted });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      textAlign: TextAlign.left,
      style: theme.primaryTextSecondary,
      textCapitalization: TextCapitalization.words,
      cursorColor: theme.accentColor,
      textInputAction: TextInputAction.done,
      initialValue: value,
      decoration: InputDecoration(
        fillColor: theme.primaryColor,
        labelText: label,
        labelStyle: theme.primaryTextSecondary,
        errorText: showErrorText ? error : null,
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
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }
}
