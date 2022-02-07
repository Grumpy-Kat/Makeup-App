import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart' as theme;
import '../types.dart';

class DoubleField extends StatelessWidget {
  final String label;
  final double? value;
  final OnDoubleAction onChange;

  final EdgeInsets? outerPadding;

  final bool isEditing;

  DoubleField({ required this.label, this.value, required this.onChange, this.outerPadding, this.isEditing = true });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: outerPadding ?? const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              style: theme.primaryTextPrimary,
              controller: TextEditingController()..text = (value == null ? '' : value.toString()),
              textAlign: TextAlign.left,
              onChanged: (String val) {
                onChange(double.parse(val));
                },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              enabled: isEditing,
              decoration: InputDecoration(
                fillColor: isEditing ? theme.primaryColorLight : theme.bgColor,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.bgColor,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.accentColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
