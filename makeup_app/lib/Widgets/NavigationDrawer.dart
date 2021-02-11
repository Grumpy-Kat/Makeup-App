import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../types.dart';
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../localizationIO.dart';

class NavigationDrawer extends StatelessWidget {
  final int currTab;
  final OnVoidAction onExit;

  Map<int, routes.ScreenRoutes> menus;

  NavigationDrawer({ Key key, this.currTab, this.onExit }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    menus = {
      0: routes.ScreenRoutes.AllSwatchesScreen,
      1: routes.ScreenRoutes.SavedLooksScreen,
      2: routes.ScreenRoutes.TodayLookScreen,
      3: routes.ScreenRoutes.ColorWheelScreen,
      4: routes.ScreenRoutes.PaletteScannerScreen,
      5: routes.ScreenRoutes.SettingsScreen,
    };
    Color selectedColor = theme.accentColor;
    TextStyle selectedText = TextStyle(color: theme.accentColorDark, fontSize: theme.primaryTextSize, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: theme.fontFamily);
    Color unselectedColor = theme.primaryColorDarkest;
    TextStyle unselectedText = theme.primaryTextPrimary;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(left: 7),
        children: <Widget>[
          //title
          DrawerHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'GlamKit',
                style: theme.primaryTitle,
              ),
            ),
          ),
          //0 = AllSwatchesScreen
          ListTile(
            leading: Icon(
              Icons.all_inclusive,
              size: theme.primaryIconSize,
              color: currTab == 0 ? selectedColor : unselectedColor,
              semanticLabel: 'All Swatches',
            ),
            title: Text(
              getString('screen_allSwatches'),
              style: currTab == 0 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 0); },
          ),
          //1 = SavedLooksScreen
          ListTile(
            leading: Icon(
              Icons.save,
              size: theme.primaryIconSize,
              color: currTab == 1 ? selectedColor : unselectedColor,
              semanticLabel: 'Saved Looks',
            ),
            title: Text(
              getString('screen_savedLooks'),
              style: currTab == 1 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 1); },
          ),
          //2 = TodayLookScreen
          ListTile(
            leading: Icon(
              Icons.today,
              size: theme.primaryIconSize,
              color: currTab == 2 ? selectedColor : unselectedColor,
              semanticLabel: 'Today\'s Look',
            ),
            title: Text(
              getString('screen_todayLook'),
              style: currTab == 2 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 2); },
          ),
          //3 = ColorWheelScreen
          ListTile(
            leading: Icon(
              Icons.colorize,
              size: theme.primaryIconSize,
              color: currTab == 3 ? selectedColor : unselectedColor,
              semanticLabel: 'Color Wheel',
            ),
            title: Text(
              getString('screen_colorWheel'),
              style: currTab == 3 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 3); },
          ),
          //4 = PaletteScannerScreen
          ListTile(
            leading: Icon(
              Icons.linked_camera,
              size: theme.primaryIconSize,
              color: currTab == 4 ? selectedColor : unselectedColor,
              semanticLabel: 'Palette Scanner',
            ),
            title: Text(
              getString('screen_paletteScanner'),
              style: currTab == 4 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 4); },
          ),
          //5 = SettingsScreen
          ListTile(
            leading: Icon(
              Icons.settings,
              size: theme.primaryIconSize,
              color: currTab == 5 ? selectedColor : unselectedColor,
              semanticLabel: 'Settings',
            ),
            title: Text(
              getString('screen_settings'),
              style: currTab == 5 ? selectedText : unselectedText,
            ),
            onTap: () { routePage(context, 5); },
          ),
        ],
      ),
    );
  }

  void routePage(BuildContext context, int page) async {
    if(!menus.containsKey(page)) {
      return;
    }
    /*if(page > currTab) {
      pos = Offset(1.0, 0.0);
    }*/
    if(page != currTab) {
      await onExit();
      navigation.pushReplacement(
        context,
        Offset(1.0, 0.0),
        menus[page],
        routes.enumRoutes[menus[page]](context),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
