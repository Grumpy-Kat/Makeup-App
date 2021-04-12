import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../IO/settingsIO.dart' as settingsIO;
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import 'Screen.dart';

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

  late PermissionStatus notificationStatus;

  @override
  void initState() {
    super.initState();
    //start getting notification status, as soon as possible
    getNotificationStatus();
    //add observer for when user leaves and returns to app
    WidgetsBinding.instance!.addObserver(this);
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
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 7);
    //outer container includes margin if no field below
    EdgeInsets margin = const EdgeInsets.only(bottom: 10);
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
        title = getString('screen_settings');
        body = getDefaultScreen(context, height, decoration, decorationNoBottom, padding, margin);
        break;
      case Mode.Shade:
        title = getString('settings_shade');
        body = getShadeScreen(context, height, decoration, decorationNoBottom, padding, margin);
        break;
      case Mode.Photo:
        title = getString('settings_photo');
        body = getPhotoScreen(context, height, decoration, decorationNoBottom, padding, margin);
        break;
    }
    return buildComplete(
      context,
      title,
      6,
      //back button
      leftBar: (mode == Mode.Default) ? null : globalWidgets.getBackButton(() => setState(() => mode = Mode.Default)),
      rightBar: [
        globalWidgets.getLoginButton(context),
      ],
      body: body,
    );
  }

  Widget getLabel(String text) {
    return AutoSizeText(
      text,
      style: theme.primaryTextSecondary,
      minFontSize: 9,
      maxFontSize: theme.primaryTextSecondary.fontSize!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  //shows all fields for default mode
  Widget getDefaultScreen(BuildContext context, double height, Decoration decoration, Decoration noBottomDecoration, EdgeInsets padding, EdgeInsets margin) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getDefaultLanguageField(context, height, decoration, padding, margin),
          //getDefaultNotificationsField(context, height, decoration, padding, margin),
          getDefaultSortField(context, height, noBottomDecoration, padding, margin),
          getDefaultShadeField(context, height, noBottomDecoration, padding, margin),
          getDefaultPhotoField(context, height, noBottomDecoration, padding, margin),
          getDefaultDistanceField(context, height, decoration, padding, margin),
          getDefaultHelpField(context, height, noBottomDecoration, padding, margin),
          getDefaultAboutField(context, height, noBottomDecoration, padding, margin),
          getDefaultRequestField(context, height, noBottomDecoration, padding, margin),
          getDefaultReportField(context, height, noBottomDecoration, padding, margin),
          getDefaultTermsField(context, height, noBottomDecoration, padding, margin),
          getDefaultPrivacyField(context, height, decoration, padding, margin),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_language')} '),
            ),
          ),
          Expanded(
            flex: 2,
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
                  onChanged: (String? val) { setState(() { globals.language = val ?? ''; }); },
                  underline: Container(
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: theme.primaryColorDark,
                        width: 0.0,
                      ),
                    ),
                  ),
                  items: getLanguages().map((String val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text('${getString(val)}', style: theme.primaryTextSecondary),
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
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: getLabel('${getString('settings_default_notifications')} '),
            ),
          ),
          Expanded(
            flex: 2,
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_sort')} '),
            ),
          ),
          Expanded(
            flex: 2,
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
                  onChanged: (String? val) { setState(() { globals.sort = val ?? ''; }); },
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
                      child: Text('${getString(val)}', style: theme.primaryTextSecondary),
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
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getLabel('${getString('settings_default_shade')}'),
              ),
            ),
            Expanded(
              flex: 2,
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_shade_shade')} '),
            ),
          ),
          Expanded(
            flex: 2,
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
                  onChanged: (String? val) {
                    setState(() {
                      globals.autoShadeNameMode = globals.autoShadeNameModeNames.keys.firstWhere((globals.AutoShadeNameMode key) => globals.autoShadeNameModeNames[key] == val);
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
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getLabel('${getString('settings_default_photo')}'),
              ),
            ),
            Expanded(
              flex: 2,
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
        getPhotoExsField(context, height, noBottomDecoration, padding, const EdgeInsets.symmetric(vertical: 15, horizontal: 10), Colors.grey, Colors.brown[800]!),
        getPhotoExsField(context, height, decoration, padding, const EdgeInsets.symmetric(vertical: 15, horizontal: 10), Colors.blue, Colors.pink[200]!),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_photo_brightness')} '),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_photo_red')} '),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_photo_green')} '),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_photo_blue')} '),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
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
              child: Text('${getString('settings_photo_before')}', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('${getString('settings_photo_after')}', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('${getString('settings_photo_before')}', style: theme.primaryTextTertiary),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text('${getString('settings_photo_after')}', style: theme.primaryTextTertiary),
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
              image: AssetImage('imgs/finish_matte.png'),
              colorBlendMode: BlendMode.modulate,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('imgs/finish_matte.png'),
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
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_sensitivity')} '),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 135,
                height: height - (padding.vertical * 1.5),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const Offset(1, 0),
              routes.ScreenRoutes.TutorialScreen,
              routes.routes['/tutorialScreen']!(context),
            );
          },
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(right: 3),
                child: getLabel('${getString('settings_default_help')} '),
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
        onTap: () async {
          String url = 'http://www.technegames.com/contact.php?type=feature';
          if(await canLaunch(url)) {
            await launch(url);
          } else {
            print('Can\'t launch $url');
          }
        },
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_request')} '),
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
        onTap: () async {
          String url = 'http://www.technegames.com/contact.php?type=bug';
          if(await canLaunch(url)) {
            await launch(url);
          } else {
            print('Can\'t launch $url');
          }
        },
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_report')} '),
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: globals.appName,
              applicationVersion: globals.appVersion,
              children: <Widget>[
                Text('${getString('settings_default_created')}', style: theme.primaryTextSecondary, textAlign: TextAlign.center),
              ],
            );
          },
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(right: 3),
                child: getLabel('${getString('settings_default_about')} '),
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

  //field to go to bug report link, shown in default mode
  Widget getDefaultTermsField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      child: InkWell(
        onTap: () async {
          String url = 'http://www.technegames.com/tos';
          if(await canLaunch(url)) {
            await launch(url);
          } else {
            print('Can\'t launch $url');
          }
        },
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_terms')} '),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                child: Icon(
                  Icons.description,
                  size: theme.primaryIconSize,
                  color: theme.tertiaryTextColor,
                  semanticLabel: 'Terms of Service',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //field to go to bug report link, shown in default mode
  Widget getDefaultPrivacyField(BuildContext context, double height, Decoration decoration, EdgeInsets padding, EdgeInsets margin) {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: InkWell(
        onTap: () async {
          String url = 'http://www.technegames.com/privacy';
          if(await canLaunch(url)) {
            await launch(url);
          } else {
            print('Can\'t launch $url');
          }
        },
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(right: 3),
              child: getLabel('${getString('settings_default_privacy')} '),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                child: Icon(
                  Icons.security,
                  size: theme.primaryIconSize,
                  color: theme.tertiaryTextColor,
                  semanticLabel: 'Privacy Policy',
                ),
              ),
            ),
          ],
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
            child: globalWidgets.getFlatButton(
              splashColor: theme.errorTextColor.withAlpha(130),
              onPressed: () async {
                //confirms clearing
                globalWidgets.openTwoButtonDialog(
                  context,
                  getString('settings_default_resetQuestion'),
                  () async {
                    await settingsIO.clear();
                    await allSwatchesIO.clear();
                    await savedLooksIO.clearAll();
                    globals.hasDoneTutorial = true;
                    globals.currSwatches.set([]);
                    navigation.pushReplacement(
                      context,
                      const Offset(1.0, 0.0),
                      routes.ScreenRoutes.AllSwatchesScreen,
                      routes.routes['/allSwatchesScreen']!(context),
                    );
                  },
                  () { },
                );
                print('reset all');
              },
              child: AutoSizeText(
                getString('settings_default_reset'),
                textAlign: TextAlign.center,
                style: theme.errorText,
                maxLines: 1,
                maxFontSize: theme.errorText.fontSize!,
                minFontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
