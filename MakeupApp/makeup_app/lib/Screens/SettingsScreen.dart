import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification_permissions/notification_permissions.dart';
import '../Screens/Screen.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;

enum Mode {
  Default,
  Shade,
  Photo,
}

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with ScreenState, WidgetsBindingObserver {
  Mode mode = Mode.Default;

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
    String title;
    Widget body;
    switch(mode) {
      case Mode.Default:
        title = 'Settings';
        body = Column(
          children: <Widget>[
            getDefaultLanguageField(context, height, decoration, padding, margin),
            getDefaultNotificationsField(context, height, decoration, padding, margin),
            getDefaultSortField(context, height, decorationNoBottom, padding, margin),
            getDefaultShadeField(context, height, decorationNoBottom, padding, margin),
            getDefaultPhotoField(context, height, decoration, padding, margin),
            getDefaultHelpField(context, height, decorationNoBottom, padding, margin),
            getDefaultReportField(context, height, decorationNoBottom, padding, margin),
            getDefaultAboutField(context, height, decoration, padding, margin),
          ],
        );
        break;
      case Mode.Shade:
        title = 'Auto Shade Name Settings';
        body = getShadeScreen(context, height, decoration, decorationNoBottom, padding, margin);
        break;
      case Mode.Photo:
        title = 'Photo Upload Settings';
        body = getPhotoScreen(context, height, decoration, decorationNoBottom, padding, margin);
        break;
    }
    return buildComplete(
      context,
      title,
      4,
      leftBar: (mode == Mode.Default) ? null : IconButton(
        color: theme.iconTextColor,
        icon: Icon(
          Icons.arrow_back,
          size: theme.primaryIconSize,
        ),
        onPressed: () {
          setState(() {
            mode = Mode.Default;
          });
        },
      ),
      body: body,
    );
  }

  Widget getDefaultLanguageField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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

  Widget getDefaultNotificationsField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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

  Widget getDefaultSortField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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

  Widget getDefaultShadeField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: InkWell(
        onTap: () {
          setState(() {
            mode = Mode.Shade;
          });
        },
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

  Widget getShadeScreen(BuildContext context, double height, Decoration decoration, Decoration noBottomDecoration, EdgeInsets padding, EdgeInsets margin) {
    return Column(
      children: <Widget>[
        getShadeShadeField(context, height, decoration, padding, margin),
        //text description
        Container(
          alignment: Alignment.topLeft,
          height: height,
          padding: padding,
          margin: margin,
          child: Text('${globals.autoShadeNameModeDescriptions[globals.autoShadeNameMode]}', style: theme.primaryTextSecondary),
        ),
      ],
    );
  }

  Widget getShadeShadeField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
            child: Text('Auto Name Shades ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                child: DropdownButton<String>(
                  iconSize: theme.primaryIconSize,
                  isDense: true,
                  isExpanded: true,
                  style: theme.primaryTextSecondary,
                  iconEnabledColor: theme.iconTextColor,
                  value: globals.autoShadeNameModeNames[globals.autoShadeNameMode],
                  onChanged: (String val) {
                    setState(() {
                      globals.autoShadeNameMode = globals.autoShadeNameModeNames.keys.firstWhere(
                        (globals.AutoShadeNameMode key) => globals.autoShadeNameModeNames[key] == val,
                        orElse: () => null,
                      );
                    });
                  },
                  underline: Container(
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 0.0,
                      ),
                    ),
                  ),
                  items: globals.autoShadeNameModeNames.values.map((String val) {
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

  Widget getDefaultPhotoField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: InkWell(
        onTap: () {
          setState(() {
            mode = Mode.Photo;
          });
        },
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

  Widget getPhotoScreen(BuildContext context, double height, Decoration decoration, Decoration noBottomDecoration, EdgeInsets padding, EdgeInsets margin) {
    return Column(
      children: <Widget>[
        getPhotoBrightnessField(context, height, noBottomDecoration, padding, margin),
        getPhotoRedField(context, height, noBottomDecoration, padding, margin),
        getPhotoGreenField(context, height, noBottomDecoration, padding, margin),
        getPhotoBlueField(context, height, decoration, padding, margin),
        getPhotoTitleField(context, height, noBottomDecoration, padding, margin),
        getPhotoExsField(context, height, noBottomDecoration, padding, EdgeInsets.symmetric(vertical: 15, horizontal: 10), Colors.grey, Colors.brown[800]),
        getPhotoExsField(context, height, decoration, padding, EdgeInsets.symmetric(vertical: 15, horizontal: 10), Colors.blue, Colors.pink[200]),
      ],
    );
  }

  Widget getPhotoBrightnessField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text('Brightness Offset ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  initialValue: globals.brightnessOffset.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    setState(() {
                      globals.brightnessOffset = int.parse(val).clamp(-255, 255);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhotoRedField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text('Red Offset ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  initialValue: globals.redOffset.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    setState(() {
                      globals.redOffset = int.parse(val).clamp(-255, 255);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhotoGreenField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: 3),
            child: Text('Green Offset ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  initialValue: globals.greenOffset.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    setState(() {
                      globals.greenOffset = int.parse(val).clamp(-255, 255);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhotoBlueField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
            child: Text('Blue Offset ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  initialValue: globals.blueOffset.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  ],
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    fillColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (String val) {
                    setState(() {
                      globals.blueOffset = int.parse(val).clamp(-255, 255);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhotoTitleField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height / 2,
      padding: EdgeInsets.only(top: padding.top),
      margin: EdgeInsets.only(bottom: margin.bottom / 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('Before', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('After', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('Before', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('After', style: theme.primaryTextTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhotoExsField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin, Color color1, Color color2) {
    return Container(
      height: height,
      margin: margin,
      child: Row(
        children: <Widget>[
          Expanded(
            child: getPhotoExField(context, height, decoration, padding, margin, color1),
          ),
          Expanded(
            child: getPhotoExField(context, height, decoration, padding, margin, color2),
          ),
        ],
      ),
    );
  }

  Widget getPhotoExField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('imgs/matte.png'),
              colorBlendMode: BlendMode.modulate,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('imgs/matte.png'),
              colorBlendMode: BlendMode.modulate,
              color: Color.fromRGBO(
                (color.red + globals.redOffset + globals.brightnessOffset).clamp(0, 255),
                (color.green + globals.greenOffset + globals.brightnessOffset).clamp(0, 255),
                (color.blue + globals.blueOffset + globals.brightnessOffset).clamp(0, 255),
                color.opacity,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDefaultHelpField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
  
  Widget getDefaultReportField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
  
  Widget getDefaultAboutField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
