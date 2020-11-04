import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';
import '../Screens/Screen.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with ScreenState, WidgetsBindingObserver {
  PermissionStatus notificationStatus;

  @override
  void initState() {
    super.initState();
    getNotificationStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      getNotificationStatus();
    }
  }

  void getNotificationStatus() {
    NotificationPermissions.getNotificationPermissionStatus().then((status) {
      setState(() {
        notificationStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = 60;
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15, vertical: 10);
    EdgeInsets margin = EdgeInsets.only(bottom: 10);
    Decoration decoration = BoxDecoration(
      color: theme.primaryColor,
      border: Border.all(color: theme.primaryColorDark),
    );
    Decoration decorationNoBottom = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
        left: BorderSide(
          color: theme.primaryColorDark,
        ),
        right: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    return buildComplete(
      context,
      'Settings',
      4,
      [],
      Column(
        children: <Widget>[
          getLanguageField(context, height, decoration, padding, margin),
          getNotificationsField(context, height, decoration, padding, margin),
          getSortField(context, height, decorationNoBottom, padding, margin),
          getShadeField(context, height, decorationNoBottom, padding, margin),
          getPhotoField(context, height, decoration, padding, margin),
          getHelpField(context, height, decorationNoBottom, padding, margin),
          getReportField(context, height, decorationNoBottom, padding, margin),
          getAboutField(context, height, decoration, padding, margin),
        ],
      ),
    );
  }

  Widget getLanguageField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text('Language ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                child: DropdownButton<String>(
                  iconSize: theme.primaryIconSize,
                  isDense: true,
                  isExpanded: true,
                  style: theme.primaryTextSecondary,
                  iconEnabledColor: theme.iconTextColor,
                  value: globals.language,
                  onChanged: (String val) { setState(() { globals.language = val; }); },
                  underline: Container(
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 0.0,
                      ),
                    ),
                  ),
                  items: globals.languages.map((String val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text('$val', style: theme.primaryTextSecondary),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getNotificationsField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: Row(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Allow Notifications ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                child: Switch.adaptive(
                  activeColor: theme.accentColor,
                  inactiveTrackColor: theme.primaryColorLight,
                  inactiveThumbColor: theme.primaryColorLight,
                  value: (notificationStatus == PermissionStatus.granted),
                  onChanged: (bool val) {
                    NotificationPermissions.requestNotificationPermissions(
                      iosSettings: NotificationSettingsIos(
                        sound: val,
                        badge: val,
                        alert: val,
                      ),
                    ).then((value) { getNotificationStatus(); });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSortField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text('Default Sort ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                child: DropdownButton<String>(
                  iconSize: theme.primaryIconSize,
                  isDense: true,
                  isExpanded: true,
                  style: theme.primaryTextSecondary,
                  iconEnabledColor: theme.iconTextColor,
                  value: globals.sort,
                  onChanged: (String val) { setState(() { globals.sort = val; }); },
                  underline: Container(
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 0.0,
                      ),
                    ),
                  ),
                  items: globals.defaultSortOptions([]).keys.map((String val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text('$val', style: theme.primaryTextSecondary),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getShadeField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: InkWell(
        onTap: () { },
        child: Row(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Auto Shade Naming', style: theme.primaryTextSecondary),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: theme.tertiaryTextSize,
                    color: theme.secondaryTextColor,
                    semanticLabel: 'Auto Shade Naming',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPhotoField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: InkWell(
        onTap: () { },
        child: Row(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Photo Upload', style: theme.primaryTextSecondary),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: theme.tertiaryTextSize,
                    color: theme.secondaryTextColor,
                    semanticLabel: 'Photo Upload',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getHelpField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () { },
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(right: 3),
                child: Text('Help ', style: theme.primaryTextSecondary),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: Icon(
                    Icons.help,
                    size: theme.secondaryIconSize,
                    color: theme.tertiaryTextColor,
                    semanticLabel: 'Help',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget getReportField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: InkWell(
        onTap: () { },
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(right: 3),
              child: Text('Report a Bug ', style: theme.primaryTextSecondary),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                child: Icon(
                  Icons.bug_report,
                  size: theme.primaryIconSize,
                  color: theme.tertiaryTextColor,
                  semanticLabel: 'Report a Bug',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget getAboutField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
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
                Text('Created by TechneGames', style: theme.primaryTextSecondary, textAlign: TextAlign.center),
              ],
            );
          },
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(right: 3),
                child: Text('About ', style: theme.primaryTextSecondary),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: Icon(
                    Icons.info,
                    size: theme.secondaryIconSize,
                    color: theme.tertiaryTextColor,
                    semanticLabel: 'About',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
