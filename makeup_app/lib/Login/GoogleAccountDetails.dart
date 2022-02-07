import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import 'SignOutButton.dart';

class GoogleAccountDetails extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  final User user;

  GoogleAccountDetails({ required this.horizontalPadding, required this.verticalPadding, required this.user });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 14),
          child: Text(
            '${getString('account_google')}',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),

        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, bottom: 3),
          child: Row(
            children: <Widget>[
              Text(
                '${getString('account_email')}: ',
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
        ),

        SignOutButton(
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
        ),
      ],
    );
  }
}
