import 'package:flutter/material.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../types.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String value;
  final OnStringAction onChange;

  final EdgeInsets? outerPadding;

  final bool isEditing;

  DropdownField({ required this.label, required this.options, required this.value, required this.onChange, this.outerPadding, this.isEditing = true });

  @override
  Widget build(BuildContext context) {
    String valueText = value;
    if(valueText.contains('_')) {
      valueText = getString(valueText, defaultValue: valueText);
    }

    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: outerPadding ?? const EdgeInsets.only(left: 30, right: 30, bottom: 10),
        child: Row(
          children: <Widget>[
            Text(
              '$label: ',
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),

            Expanded(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isEditing ? theme.primaryColorLight : theme.bgColor,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: isEditing ? theme.primaryColorDark : theme.bgColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: DropdownButton<String>(
                disabledHint: Text('$valueText', style: theme.primaryTextPrimary),
                isDense: true,
                isExpanded: true,
                style: theme.primaryTextPrimary,
                value: value,
                onChanged: !isEditing ? null : (String? value) {
                  if(isEditing) {
                    onChange(value ?? '');
                  }
                },
                icon: null,
                iconSize: 0,
                underline: Container(),
                items: options.map(
                  (String val) {
                    String text = val;
                    if(text.contains('_')) {
                      text = getString(text, defaultValue: text);
                    }

                    return DropdownMenuItem(
                      value: val,
                      child: Text('$text', style: theme.primaryTextPrimary),
                    );
                  }
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
