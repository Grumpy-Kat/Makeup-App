import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class PhoneLogin extends StatefulWidget {
  final bool hasAccount;

  PhoneLogin(this.hasAccount);

  @override
  PhoneLoginState createState() => PhoneLoginState();
}

class PhoneLoginState extends State<PhoneLogin> {
  late PhoneNumberTextInputFormatter _phoneNumberTextInputFormatter;
  String _countryCode = '1';

  bool _hasSentMsg = false;

  String _error = '';

  @override
  void initState() {
    super.initState();
    _phoneNumberTextInputFormatter = PhoneNumberTextInputFormatter(_countryCode);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget btn;
    if(_hasSentMsg) {
      child = getMessageCodeField(context);
      btn = globalWidgets.getFlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          //TODO
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.hasAccount ? 'Login' : 'Sign Up',
            style: theme.accentTextBold,
          ),
        ),
      );
    } else {
      child = getPhoneNumberFields(context);
      btn = globalWidgets.getFlatButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        bgColor: theme.accentColor,
        onPressed: () {
          //TODO
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Send Message',
            style: theme.accentTextBold,
          ),
        ),
      );
    }
    return Column(
      children: <Widget>[
        child,
        const SizedBox(
          height: 7,
        ),
        btn,
        if(_error != '') Text(_error, style: theme.errorText),
      ],
    );
  }

  Widget getMessageCodeField(BuildContext context) {
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
        textInputAction: TextInputAction.done,
        autofocus: true,
        style: theme.primaryTextPrimary,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.accentColor,
        decoration: InputDecoration(
          hintText: 'Code',
          hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget getPhoneNumberFields(BuildContext context) {
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
              initialValue: '+' + _countryCode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofocus: true,
              onChanged: (String val) {
                if(val[0] == '+') {
                  _countryCode = val.substring(1);
                } else {
                  _countryCode = val;
                }
                _phoneNumberTextInputFormatter.countryCode = _countryCode;
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

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  String countryCode;

  PhoneNumberTextInputFormatter(this.countryCode);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue orgVal, TextEditingValue newVal) {
    int length = newVal.text.length;
    int selection = newVal.selection.end;
    int substringIndex = 0;
    String text = '';
    switch(countryCode) {
      case '1':
      case '52':
      case '98': {
        //United States, Canada, Mexico, Iran, etc.
        if(length >= 1) {
          text += '(';
          if(newVal.selection.end >= 1) {
            selection++;
          }
        }
        if(length >= 4) {
          text += newVal.text.substring(0, substringIndex = 3) + ') ';
          if(newVal.selection.end >= 3) {
            selection += 2;
          }
        }
        if(length >= 7) {
          text += newVal.text.substring(3, substringIndex = 6) + ' - ';
          if(newVal.selection.end >= 6) {
            selection += 3;
          }
        }
        break;
      }
      case '33':
      case '212': {
        //France and Morocco
        if(length >= 1) {
          text += newVal.text.substring(0, substringIndex = 1) + ' ';
          if(newVal.selection.end >= 2) {
            selection++;
          }
        }
        if(length >= 3) {
          int end = length;
          if(length % 2 == 0) {
            end = length - 1;
          }
          if(length > 9) {
            end = 9;
          }
          for(int i = 1; i < end; i += 2) {
            text += newVal.text.substring(i, substringIndex = substringIndex + 2) + ' ';
            if(newVal.selection.end >= substringIndex + 1) {
              selection++;
            }
          }
        }
        break;
      }
      case '61':
      case '86': {
        //China
        if(length >= 3) {
          text += newVal.text.substring(0, substringIndex = 3) + ' ';
          if(newVal.selection.end >= 4) {
            selection++;
          }
        }
        if(length >= 6) {
          text += newVal.text.substring(3, substringIndex = 6) + ' ';
          if(newVal.selection.end >= 7) {
            selection++;
          }
        }
        break;
      }
      case '64': {
        //New Zealand
        if(length >= 2) {
          text += newVal.text.substring(0, substringIndex = 2) + ' ';
          if(newVal.selection.end >= 3) {
            selection++;
          }
        }
        if(length >= 5) {
          text += newVal.text.substring(2, substringIndex = 5) + ' ';
          if(newVal.selection.end >= 6) {
            selection++;
          }
        }
        break;
      }
      case '49':
      case '65':
      case '852':
      case '853': {
        //Germany, Singapore, Hong Kong, Macau, etc.
        if(length >= 4) {
          text += newVal.text.substring(0, substringIndex = 4) + ' ';
          if(newVal.selection.end >= 5) {
            selection++;
          }
        }
        break;
      }
      case '7': {
        //Russia
        if(length >= 3) {
          text += newVal.text.substring(0, substringIndex = 3) + ' ';
          if(newVal.selection.end >= 4) {
            selection++;
          }
        }
        if(length >= 6) {
          text += newVal.text.substring(3, substringIndex = 6) + ' ';
          if(newVal.selection.end >= 7) {
            selection++;
          }
        }
        if(length >= 8) {
          text += newVal.text.substring(6, substringIndex = 8) + ' ';
          if(newVal.selection.end >= 9) {
            selection++;
          }
        }
        break;
      }
      case '46': {
        //Sweden
        if(length >= 3) {
          text += newVal.text.substring(0, substringIndex = 3) + ' - ';
          if(newVal.selection.end >= 4) {
            selection += 3;
          }
        }
        if(length >= 6) {
          text += newVal.text.substring(3, substringIndex = 6) + ' ';
          if(newVal.selection.end >= 7) {
            selection++;
          }
        }
        if(length >= 8) {
          text += newVal.text.substring(6, substringIndex = 8) + ' ';
          if(newVal.selection.end >= 9) {
            selection++;
          }
        }
        break;
      }
      case '41':
      case '380': {
        //Switzerland and Ukraine
        if(length >= 2) {
          text += newVal.text.substring(0, substringIndex = 2) + ' ';
          if(newVal.selection.end >= 3) {
            selection++;
          }
        }
        if(length >= 5) {
          text += newVal.text.substring(2, substringIndex = 5) + ' ';
          if(newVal.selection.end >= 6) {
            selection++;
          }
        }
        if(length >= 7) {
          text += newVal.text.substring(5, substringIndex = 7) + ' ';
          if(newVal.selection.end >= 8) {
            selection++;
          }
        }
        break;
      }
      case '34':
      case '351': {
        //Spain and Portugal
        if(length >= 3) {
          text += newVal.text.substring(0, substringIndex = 3) + ' ';
          if(newVal.selection.end >= 4) {
            selection++;
          }
        }
        if(length >= 6) {
          text += newVal.text.substring(3, substringIndex = 6) + ' ';
          if(newVal.selection.end >= 7) {
            selection++;
          }
        }
        break;
      }
      case '48': {
        //Poland
        if(length >= 3) {
          text += newVal.text.substring(0, substringIndex = 3) + ' - ';
          if(newVal.selection.end >= 4) {
            selection += 3;
          }
        }
        if(length >= 6) {
          text += newVal.text.substring(3, substringIndex = 6) + ' - ';
          if(newVal.selection.end >= 7) {
            selection += 3;
          }
        }
        break;
      }
      case '91': {
        //India
        if(length >= 5) {
          text += newVal.text.substring(0, substringIndex = 5) + ' ';
          if(newVal.selection.end >= 6) {
            selection++;
          }
        }
        break;
      }
    }
    if(length >= substringIndex) {
      text += newVal.text.substring(substringIndex);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selection),
    );
  }
}

class CountryCodeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue orgVal, TextEditingValue newVal) {
    String text = newVal.text;
    int selection = newVal.selection.end;
    if(newVal.text.length >= 1) {
      text = '+${newVal.text}';
      selection++;
      if(text.length > 4) {
        text = text.substring(0, 4);
        if(selection > 4) {
          selection = 4;
        }
      }
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selection),
    );
  }
}

