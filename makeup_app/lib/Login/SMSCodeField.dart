import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;

class SMSCodeField extends StatefulWidget {
  SMSCodeField({ Key? key }) : super(key: key);

  @override
  SMSCodeFieldState createState() => SMSCodeFieldState();
}

class SMSCodeFieldState extends State<SMSCodeField> {
  String smsCode = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.accentColor,
            width: 2.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        autofillHints: [AutofillHints.oneTimeCode],
        textInputAction: TextInputAction.done,
        autofocus: true,
        style: TextStyle(color: theme.primaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily, letterSpacing: 7.0),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        onChanged: (String val) {
          smsCode = val;
        },
        decoration: InputDecoration(
          hintText: getString('smsCodeField_confirm'),
          hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.tertiaryTextSize, fontFamily: theme.fontFamily, letterSpacing: 0.78),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

