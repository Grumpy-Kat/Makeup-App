import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart' as theme;
import 'PhoneNumberTextInputFormatter.dart';

class PhoneNumberField extends StatefulWidget {
  PhoneNumberField({ Key? key }) : super(key: key);

  @override
  PhoneNumberFieldState createState() => PhoneNumberFieldState();
}

class PhoneNumberFieldState extends State<PhoneNumberField> {
  late PhoneNumberTextInputFormatter _phoneNumberTextInputFormatter;
  String countryCode = '1';
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumberTextInputFormatter = PhoneNumberTextInputFormatter(countryCode);
  }

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
          borderRadius: const BorderRadius.all(Radius.circular(7)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextFormField(
              textAlign: TextAlign.left,
              initialValue: '+' + countryCode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofocus: true,
              onChanged: (String val) {
                if(val[0] == '+') {
                  countryCode = val.substring(1);
                } else {
                  countryCode = val;
                }
                _phoneNumberTextInputFormatter.countryCode = countryCode;
              },
              style: theme.primaryTextPrimary,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                CountryCodeTextInputFormatter(),
              ],
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: theme.accentColor,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: TextFormField(
              textAlign: TextAlign.left,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: theme.primaryTextPrimary,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                _phoneNumberTextInputFormatter,
              ],
              onChanged: (String val) {
                phoneNumber = val;
              },
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: theme.accentColor,
              decoration: InputDecoration(
                hintText: 'Your Phone Number',
                hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

