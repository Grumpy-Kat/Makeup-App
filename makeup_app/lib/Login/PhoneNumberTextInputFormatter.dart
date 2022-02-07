import 'package:flutter/services.dart';

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
