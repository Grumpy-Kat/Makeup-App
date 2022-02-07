import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';

class StringField extends StatelessWidget {
  final String label;
  final String? value;
  final OnStringAction onChange;

  final EdgeInsets? outerPadding;

  final bool isEditing;

  StringField({ required this.label, this.value, required this.onChange, this.isEditing = true, this.outerPadding });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: outerPadding ?? EdgeInsets.only(bottom: 10),
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
              controller: TextEditingController()..text = value ?? '',
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.left,
              onChanged: onChange,
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
