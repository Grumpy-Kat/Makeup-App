import 'package:flutter/material.dart' hide FlatButton, OutlineButton, BackButton;
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/Screen.dart';
import '../Widgets/BackButton.dart';
import '../IO/localizationIO.dart';
import '../IO/loginIO.dart' as IO;
import '../navigation.dart' as navigation;
import 'LoginAuthType.dart';
import 'EmailAccountDetails.dart';
import 'GoogleAccountDetails.dart';
import 'PhoneAccountDetails.dart';

class AccountScreen extends StatefulWidget {
  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with ScreenState {
  late LoginAuthType _type;

  @override
  void initState() {
    super.initState();

    User? user = IO.auth.currentUser;

    if(user != null) {
      if(user.phoneNumber != null) {
        _type = LoginAuthType.Phone;
      } else if(user.email != null) {
        if (user.providerData[0].providerId == 'google.com') {
          _type = LoginAuthType.Google;
        } else {
          _type = LoginAuthType.Email;
        }
      } else {
        print('Neither email nor phone is set, which should not happen with the current login methods! LoginAuthType can not be properly set');
        _type = LoginAuthType.Email;
      }
    } else {
      print('User is null! LoginAuthType can not be properly set');
      _type = LoginAuthType.Email;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = IO.auth.currentUser;

    if(user != null) {
      double horizontalPadding = 20;
      double verticalPadding = 7;

      Widget body;
      switch(_type) {
        case LoginAuthType.Phone: {
          body = PhoneAccountDetails(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            user: user,
          );
          break;
        }
        case LoginAuthType.Email: {
          body = EmailAccountDetails(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            user: user,
          );
          break;
        }
        case LoginAuthType.Google: {
          body = GoogleAccountDetails(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            user: user,
          );
          break;
        }
      }

      return buildComplete(
        context,
        getString('screen_account'),
        21,
        //back button
        leftBar: BackButton(onPressed: () => navigation.pop(context, false)),
        body: body,
      );
    }

    return Container();
  }
}