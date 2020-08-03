import 'package:flutter/material.dart';
import '../Screens/Screen.dart';
import '../Widgets/Swatch.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

class SettingsScreen extends StatefulWidget {
  final Future<List<Swatch>> Function() loadFormatted;

  SettingsScreen(this.loadFormatted);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with ScreenState {
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.all(20);
    return buildComplete(
      context,
      widget.loadFormatted,
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
                    child: DropdownButtonFormField<String>(
                      isDense: true,
                      style: theme.primaryText,
                      value: globals.language,
                      onChanged: (String val) { globals.language = val; },
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
                  child: Text('Default Sort ', style: theme.primaryText),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<String>(
                      isDense: true,
                      style: theme.primaryText,
                      value: globals.sort,
                      onChanged: (String val) { globals.sort = val; },
                      items: globals.sortOptions.map((String val) {
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
                      Text('Created by TechneGames', style: theme.primaryTextSmall, textAlign: TextAlign.center),
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
