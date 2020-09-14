import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.all(20);
    return buildComplete(
      context,
      4,
      Column(
        children: <Widget>[
          Padding(
            padding: padding,
            child: Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Language ', style: theme.primaryText),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isDense: true,
                      style: theme.primaryText,
                      value: globals.language,
                      onChanged: (String val) { globals.language = val; },
                      underline: Container(
                        decoration: UnderlineTabIndicator(
                          insets: EdgeInsets.only(bottom: -10),
                          borderSide: BorderSide(
                            color: theme.primaryColorDark,
                            width: 1.0,
                          ),
                        ),
                      ),
                      items: globals.languages.map((String val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text('$val', style: theme.primaryText),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding,
            child: Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Allow Notifications ', style: theme.primaryText),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    child: Switch.adaptive(
                      activeColor: theme.accentColor,
                      inactiveTrackColor: theme.primaryColorLight,
                      inactiveThumbColor: theme.primaryColorLight,
                      value: false,
                      onChanged: (bool val) { },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding,
            child: InkWell(
              onTap: () { },
              child: Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Report a Bug ', style: theme.primaryText),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      child: Icon(
                        Icons.bug_report,
                        size: 30.0,
                        color: theme.primaryTextColor,
                        semanticLabel: 'Report a Bug',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: globals.appName,
                    applicationVersion: globals.appVersion,
                    children: <Widget>[
                      Text('Created by TechneGames', style: theme.primaryTextSmaller, textAlign: TextAlign.center),
                    ],
                  );
                },
                child: Text('Acknowledgements', style: theme.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
