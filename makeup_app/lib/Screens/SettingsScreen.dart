import 'package:flutter/material.dart' hide FlatButton, BackButton;
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/FlatButton.dart';
import '../Widgets/BackButton.dart';
import '../Widgets/LoginButton.dart';
import '../IO/settingsIO.dart' as settingsIO;
import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../IO/localizationIO.dart';
import '../types.dart';
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
  final double height = 55;
  final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 7);
  // Use margin if no field below
  final EdgeInsets margin = const EdgeInsets.only(bottom: 10);

  // Border and color if no field below
  final Decoration decoration = BoxDecoration(
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

  // Border and color if field below
  final Decoration decorationNoBottom = BoxDecoration(
    color: theme.primaryColor,
    border: Border(
      top: BorderSide(
        color: theme.primaryColorDark,
      ),
    ),
  );

  Mode mode = Mode.Default;

  late PermissionStatus notificationStatus;

  @override
  void initState() {
    super.initState();
    // Start getting notification status, as soon as possible
    getNotificationStatus();
    // Add observer for when user leaves and returns to app
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update notification status if user leaves and returns to app
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
    // Title and body determined by mode
    String title;
    Widget body;
    switch(mode) {
      case Mode.Default:
        title = getString('screen_settings');
        body = getDefaultScreen();
        break;
      case Mode.Shade:
        title = getString('settings_shade');
        body = getShadeScreen();
        break;
      case Mode.Photo:
        title = getString('settings_photo');
        body = getPhotoScreen();
        break;
    }

    return buildComplete(
      context,
      title,
      6,
      leftBar: (mode == Mode.Default) ? null : BackButton(onPressed: () => setState(() => mode = Mode.Default)),
      rightBar: [
        LoginButton(),
      ],
      body: body,
    );
  }

  Widget getField({ required String label, required Widget child, double? height, Decoration? decoration, bool usePadding = true, bool useMargin = true, bool useLabelPadding = true }) {
    return Container(
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      padding: usePadding ? padding : EdgeInsets.zero,
      margin: useMargin ? margin : EdgeInsets.zero,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: useLabelPadding ? const EdgeInsets.only(right: 3) : EdgeInsets.zero,
              child: getLabel(label),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget getFieldWithIcon({ required String label, required IconData icon, required OnVoidAction onTap, double? height, Decoration? decoration, bool usePadding = true, bool useMargin = true, double? iconSize }) {
    return Container(
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      padding: usePadding ? padding : EdgeInsets.zero,
      margin: useMargin ? margin : EdgeInsets.zero,
      child: Align(
        alignment: Alignment.centerLeft,
          child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(right: 3),
                child: getLabel(label),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: Icon(
                    icon,
                    size: iconSize ?? theme.primaryIconSize,
                    color: theme.tertiaryTextColor,
                    semanticLabel: '${getString(label)} ',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget getModeField({ required String label, required Mode mode }) {
    return Container(
      height: height,
      decoration: decorationNoBottom,
      padding: padding,
      child: InkWell(
        onTap: () {
          setState(() {
            this.mode = mode;
          });
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getLabel(label),
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
                    semanticLabel: '${getString(label)} ',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDropdownField({ required String label, required String initialValue, required Iterable<String> values, required OnStringAction onChanged, double? width, Decoration? decoration, bool useMargin = true }) {
    return getField(
      decoration: decoration,
      useMargin: useMargin,
      label: label,
      child: SizedBox(
        width: width ?? 135,
        child: DropdownButton<String>(
          iconSize: theme.primaryIconSize,
          isDense: true,
          isExpanded: true,
          style: theme.primaryTextSecondary,
          iconEnabledColor: theme.iconTextColor,
          value: initialValue,
          onChanged: (String? val) {
            setState(() {
              onChanged(val ?? '');
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
          items: values.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text('${getString(val)}', style: theme.primaryTextSecondary),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Shows all fields for default mode
  Widget getDefaultScreen() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getDefaultLanguageField(),

          //getDefaultNotificationsField(),

          getDefaultSortField(),
          // Field to go to auto shade naming mode
          getModeField(label: '${getString('settings_default_shade')}', mode: Mode.Shade),
          // Field to go to photo upload settings mode
          getModeField(label: '${getString('settings_default_photo')}', mode: Mode.Photo),
          getDefaultDistanceField(),

          getDefaultHelpField(),
          getDefaultAboutField(),
          getDefaultRequestField(),
          getDefaultReportField(),
          getDefaultTermsField(),
          getDefaultPrivacyField(),

          getDefaultResetField(),
        ],
      ),
    );
  }

  // Field to choose localization language, shown in default mode
  Widget getDefaultLanguageField() {
    return getDropdownField(
      label: '${getString('settings_default_language')} ',
      initialValue: globals.language,
      values: getLanguages(),
      onChanged: (String val) { globals.language = val; },
    );
  }

  // Field to choose whether to show notifications, shown in default mode
  Widget getDefaultNotificationsField() {
    return getField(
      label: '${getString('settings_default_notifications')} ',
      useLabelPadding: false,
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
    );
  }

  // Field to choose default sort of swatch lists, shown in default mode
  Widget getDefaultSortField() {
    return getDropdownField(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_sort')} ',
      initialValue: globals.sort,
      values: globals.defaultSortOptions([]).keys,
      onChanged: (String val) { globals.sort = val; },
    );
  }

  // Shows all fields for auto shade name mode
  Widget getShadeScreen() {
    return Column(
      children: <Widget>[
        getShadeShadeField(),

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

  // Field to choose auto shade name mode, shown in auto shade name mode
  Widget getShadeShadeField() {
    return getDropdownField(
      width: 150,
      label: '${getString('settings_shade_shade')} ',
      initialValue: globals.autoShadeNameModeNames[globals.autoShadeNameMode]!,
      onChanged: (String val) {
        globals.autoShadeNameMode = globals.autoShadeNameModeNames.keys.firstWhere((globals.AutoShadeNameMode key) => globals.autoShadeNameModeNames[key] == val);
      },
      values: globals.autoShadeNameModeNames.values,
    );
  }

  // Shows all fields for photo upload settings mode
  Widget getPhotoScreen() {
    return Column(
      // Field to choose default brightness changes of photos
      children: <Widget>[
        getPhotoInputField(
          decoration: decorationNoBottom,
          useMargin: false,
          label: '${getString('settings_photo_brightness')} ',
          initialValue: globals.brightnessOffset,
          onChanged: (int val) {
            globals.brightnessOffset = val;
          },
        ),
        // Field to choose default red changes of photos
        getPhotoInputField(
          decoration: decorationNoBottom,
          useMargin: false,
          label: '${getString('settings_photo_red')} ',
          initialValue: globals.redOffset,
          onChanged: (int val) {
            globals.redOffset = val;
          },
        ),
        // Field to choose default green changes of photos
        getPhotoInputField(
          decoration: decorationNoBottom,
          useMargin: false,
          label: '${getString('settings_photo_green')} ',
          initialValue: globals.greenOffset,
          onChanged: (int val) {
            globals.greenOffset = val;
          },
        ),
        // Field to choose default blue changes of photos
        getPhotoInputField(
          label: '${getString('settings_photo_blue')} ',
          initialValue: globals.blueOffset,
          onChanged: (int val) {
            globals.blueOffset = val;
          },
        ),

        getPhotoTitleField(),
        getPhotoExsField(decorationNoBottom, Colors.grey, Colors.brown[800]!),
        getPhotoExsField(decoration, Colors.blue, Colors.pink[200]!),
      ],
    );
  }

  // Field to choose default color changes of photos, shown in photo upload settings mode
  Widget getPhotoInputField({ required String label, required int initialValue, required OnIntAction onChanged, Decoration? decoration, bool useMargin = true }) {
    return getField(
      decoration: decoration,
      useMargin: useMargin,
      label: label,
      child: SizedBox(
        width: 135,
        height: height - (padding.vertical * 1.5),
        child: TextFormField(
          textAlign: TextAlign.left,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          initialValue: initialValue.toString(),
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
              onChanged(int.parse(val).clamp(-255, 255));
            });
          },
        ),
      ),
    );
  }

  // Shows labels for swatch examples, shown in photo upload settings mode
  Widget getPhotoTitleField() {
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

  // Shows horizontal row of swatch examples, shown in photo upload settings mode
  Widget getPhotoExsField(Decoration decoration, Color color1, Color color2) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: getPhotoExField(decoration, color1),
          ),
          Expanded(
            child: getPhotoExField(decoration, color2),
          ),
        ],
      ),
    );
  }

  // Shows swatch examples to display change settings, shown in photo upload settings mode
  Widget getPhotoExField(Decoration decoration, Color color) {
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

  // Field to choose color wheel sensitivity, shown in default mode
  Widget getDefaultDistanceField() {
    return getField(
      label: '${getString('settings_default_sensitivity')} ',
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
    );
  }

  // Field to open help menu, shown in default mode
  Widget getDefaultHelpField() {
    return getFieldWithIcon(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_help')} ',
      icon: Icons.help,
      iconSize: theme.secondaryIconSize,
      onTap: () {
        navigation.push(
          context,
          const Offset(1, 0),
          routes.ScreenRoutes.TutorialScreen,
          routes.routes['/tutorialScreen']!(context),
        );
      },
    );
  }

  // Field to go to feature request link, shown in default mode
  Widget getDefaultRequestField() {
    return getFieldWithIcon(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_request')} ',
      icon: Icons.lightbulb,
      onTap: () async {
        String url = 'http://www.technegames.com/contact.php?type=feature';
        if(await canLaunch(url)) {
          await launch(url);
        } else {
          print('Can\'t launch $url');
        }
      },
    );
  }

  // Field to go to bug report link, shown in default mode
  Widget getDefaultReportField() {
    return getFieldWithIcon(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_report')} ',
      icon: Icons.bug_report,
      onTap: () async {
        String url = 'http://www.technegames.com/contact.php?type=bug';
        if(await canLaunch(url)) {
          await launch(url);
        } else {
          print('Can\'t launch $url');
        }
      },
    );
  }

  // Field to open about menu, shown in default mode
  Widget getDefaultAboutField() {
    return getFieldWithIcon(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_about')} ',
      icon: Icons.info,
      iconSize: theme.secondaryIconSize,
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
    );
  }

  // Field to go to bug report link, shown in default mode
  Widget getDefaultTermsField() {
    return getFieldWithIcon(
      decoration: decorationNoBottom,
      useMargin: false,
      label: '${getString('settings_default_terms')} ',
      icon: Icons.description,
      onTap: () async {
        String url = 'http://www.technegames.com/tos';
        if(await canLaunch(url)) {
          await launch(url);
        } else {
          print('Can\'t launch $url');
        }
      },
    );
  }

  // Field to go to bug report link, shown in default mode
  Widget getDefaultPrivacyField() {
    return getFieldWithIcon(
      label: '${getString('settings_default_privacy')} ',
      icon: Icons.security,
      onTap: () async {
        String url = 'http://www.technegames.com/privacy';
        if(await canLaunch(url)) {
          await launch(url);
        } else {
          print('Can\'t launch $url');
        }
      },
    );
  }

  // Button to reset all saved looks and saved swatches
  Widget getDefaultResetField() {
    return Container(
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: FlatButton(
        splashColor: theme.errorTextColor.withAlpha(130),
        onPressed: () async {
          //confirms clearing
          globalWidgets.openTwoButtonDialog(
            context,
            getString('settings_default_resetQuestion'),
            () async {
              await settingsIO.clear();
              await allSwatchesIO.clear();
              await allSwatchesStorageIO.deleteAllImgs();
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
    );
  }
}
