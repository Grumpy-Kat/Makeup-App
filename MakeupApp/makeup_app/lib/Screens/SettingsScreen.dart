import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification_permissions/notification_permissions.dart';
import '../Screens/Screen.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../settingsIO.dart' as settingsIO;
import '../allSwatchesIO.dart' as allSwatchesIO;
import '../savedLooksIO.dart' as savedLooksIO;

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
    //start getting notification status, as soon as possible
    getNotificationStatus();
    //add observer for when user leaves and returns to app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //update notification status if user leaves and returns to app
    if(state == AppLifecycleState.resumed) {
      getNotificationStatus();
    }
  }

  void getNotificationStatus() {
    //use notification_permissions library to get notification status
    NotificationPermissions.getNotificationPermissionStatus().then((status) {
      setState(() {
        //set state when finished getting notification status
        notificationStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //height of field
    double height = 55;
    //almost every field has padding
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15, vertical: 7);
    //outer container includes margin if no field below
    EdgeInsets margin = EdgeInsets.only(bottom: 10);
    //border and color if no field below
    Decoration decoration = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
        bottom: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    //border and color if field below
    Decoration decorationNoBottom = BoxDecoration(
      color: theme.primaryColor,
      border: Border(
        top: BorderSide(
          color: theme.primaryColorDark,
        ),
      ),
    );
    //title and body determined by mode
    String title;
    Widget body;
    switch(mode) {
      case Mode.Default:
        title = 'Settings';
        body = getDefaultScreen(context, height, decoration, decorationNoBottom, padding, margin);
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
      //back button
      leftBar: (mode == Mode.Default) ? null : IconButton(
        constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
        icon: Icon(
          Icons.arrow_back,
          size: theme.primaryIconSize,
          color: theme.iconTextColor,
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

  //shows all fields for default mode
  Widget getDefaultScreen(BuildContext context, double height, Decoration decoration, Decoration noBottomDecoration, EdgeInsets padding, EdgeInsets margin) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getDefaultLanguageField(context, height, decoration, padding, margin),
          getDefaultNotificationsField(context, height, decoration, padding, margin),
          getDefaultSortField(context, height, noBottomDecoration, padding, margin),
          getDefaultShadeField(context, height, noBottomDecoration, padding, margin),
          getDefaultPhotoField(context, height, noBottomDecoration, padding, margin),
          getDefaultDistanceField(context, height, decoration, padding, margin),
          getDefaultHelpField(context, height, noBottomDecoration, padding, margin),
          getDefaultRequestField(context, height, noBottomDecoration, padding, margin),
          getDefaultReportField(context, height, noBottomDecoration, padding, margin),
          getDefaultAboutField(context, height, decoration, padding, margin),
          getDefaultResetField(context, height, decoration, padding, margin),
        ],
      ),
    );
  }

  //field to choose localization language, shown in default mode
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

  //field to choose whether to show notifications, shown in default mode
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

  //field to choose default sort of swatch lists, shown in default mode
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

  //field to go to auto shade naming mode, shown in default mode
  Widget getDefaultShadeField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: InkWell(
        onTap: () {
          setState(() {
            //change mode
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

  //shows all fields for auto shade name mode
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

  //field to choose auto shade name mode, shown in auto shade name mode
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

  //field to go to photo upload settings mode, shown in default mode
  Widget getDefaultPhotoField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
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

  //shows all fields for photo upload settings mode
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

  //field to choose brightness changes of photos, shown in photo upload settings mode
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
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

  //field to choose red changes of photos, shown in photo upload settings mode
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
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

  //field to choose green changes of photos, shown in photo upload settings mode
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
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

  //field to choose blue changes of photos, shown in photo upload settings mode
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
                  keyboardType: TextInputType.numberWithOptions(signed: true),
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

  //shows labels for swatch examples, shown in photo upload settings mode
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

  //shows horizontal row of swatch examples, shown in photo upload settings mode
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

  //shows swatch examples to display change settings, shown in photo upload settings mode
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

  //field to choose brightness changes of photos, shown in photo upload settings mode
  Widget getDefaultDistanceField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
            child: Text('Color Wheel Screen Sensitivity ', style: theme.primaryTextSecondary),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: globals.colorWheelDistance.toString(),
                  textInputAction: TextInputAction.done,
                  style: theme.primaryTextSecondary,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
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
                      globals.colorWheelDistance = double.parse(val).clamp(3, 25);
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

  //field to open help menu, shown in default mode
  Widget getDefaultHelpField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            navigation.push(
              context,
              Offset(1, 0),
              routes.ScreenRoutes.TutorialScreen,
              routes.routes['/tutorialScreen'](context),
            );
          },
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

  //field to go to feature request link, shown in default mode
  Widget getDefaultRequestField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
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
              child: Text('Request a Feature', style: theme.primaryTextSecondary),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                child: Icon(
                  Icons.lightbulb,
                  size: theme.primaryIconSize,
                  color: theme.tertiaryTextColor,
                  semanticLabel: 'Request a Feature',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //field to go to bug report link, shown in default mode
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

  //field to open about menu, shown in default mode
  Widget getDefaultAboutField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
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

  //button to reset all saved looks and saved swatches
  Widget getDefaultResetField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              splashColor: theme.errorTextColor.withAlpha(130),
              onPressed: () async {
                //confirms clearing
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to reset the entire app, including settings, swatches, and looks? This can not be undone.',
                  () async {
                    await settingsIO.clear();
                    await allSwatchesIO.clear();
                    await savedLooksIO.clearIds();
                    globals.hasDoneTutorial = true;
                    globals.currSwatches.set([]);
                    navigation.pushReplacement(
                      context,
                      Offset(1.0, 0.0),
                      routes.ScreenRoutes.AllSwatchesScreen,
                      routes.routes['/allSwatchesScreen'](context),
                    );
                  },
                  () { },
                );
                print('reset all');
              },
              child: Text(
                'Reset App',
                textAlign: TextAlign.center,
                style: theme.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
