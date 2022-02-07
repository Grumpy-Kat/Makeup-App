import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart' as theme;
import '../types.dart';

class DoubleFormField extends StatelessWidget {
  final String? label;
  final double? value;

  final String? error;
  final bool showErrorText;

  final OnDoubleAction? onChanged;
  final OnDoubleAction? onSubmitted;

  DoubleFormField({ this.label, this.value, this.error, this.showErrorText = false, this.onChanged, this.onSubmitted });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      textAlign: TextAlign.left,
      style: theme.primaryTextSecondary,
      textInputAction: TextInputAction.done,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      cursorColor: theme.accentColor,
      initialValue: value.toString(),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
      ],
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
      onChanged: (String val) {
        if(onChanged != null) {
          onChanged!(double.parse(val));
        }
      },
      onFieldSubmitted: (String val) {
        if(onSubmitted != null) {
          onSubmitted!(double.parse(val));
        }
      },
    );
  }
}
