import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Screens/Screen.dart';
import '../IO/loginIO.dart' as IO;
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../theme.dart' as theme;
import 'LoginScreen.dart';

class AccountScreen extends StatefulWidget {
  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    //TODO: finish this
    User? user = IO.auth.currentUser;
    if(user != null) {
      return buildComplete(
        context,
        'Account',
        21,
        //back button
        leftBar: globalWidgets.getBackButton(() => navigation.pop(context, false)),
        body: Column(
          children: <Widget>[
            if(user.phoneNumber != null) getPhoneNumberField(context, user),
            if(user.email != null) getEmailField(context, user),
            if(user.email != null && user.providerData[0].providerId == 'google.com') getPasswordField(context, user),
            globalWidgets.getOutlineButton(
              bgColor: theme.bgColor,
              outlineColor: theme.primaryColorDark,
              outlineWidth: 2.0,
              onPressed: () {
                IO.signOut().then(
                  (value) {
                    navigation.pushReplacement(
                      context,
                      const Offset(1, 0),
                      routes.ScreenRoutes.LoginScreen,
                      LoginScreen(true),
                    );
                  },
                );
              },
              child: Text(
                'Sign Out',
                style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget getPhoneNumberField(BuildContext context, User user) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            'Phone Number: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: TextFormField(
              scrollPadding: EdgeInsets.zero,
              keyboardType: TextInputType.phone,
              style: theme.primaryTextPrimary,
              initialValue: user.phoneNumber,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.left,
              enabled: false,
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getEmailField(BuildContext context, User user) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            'Email: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: TextFormField(
              scrollPadding: EdgeInsets.zero,
              keyboardType: TextInputType.emailAddress,
              style: theme.primaryTextPrimary,
              initialValue: user.email,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.left,
              enabled: false,
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPasswordField(BuildContext context, User user) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            'Password: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                IO.auth.sendPasswordResetEmail(email: user.email ?? '');
              },
              child: Text(
                'Reset Password.',
                style: TextStyle(color: theme.primaryTextColor, fontSize: theme.primaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
