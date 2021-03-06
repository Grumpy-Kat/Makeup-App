import 'package:flutter/material.dart';
import '../types.dart';
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;

class MenuBar extends StatelessWidget {
  final int currTab;
  final OnVoidAction? onExit;

  late Map<int, routes.ScreenRoutes> menus;

  MenuBar({ Key? key, required this.currTab, this.onExit }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    menus = {
      0: routes.ScreenRoutes.AllSwatchesScreen,
      1: routes.ScreenRoutes.SavedLooksScreen,
      2: routes.ScreenRoutes.ColorWheelScreen,
      3: routes.ScreenRoutes.PaletteScannerScreen,
      4: routes.ScreenRoutes.SettingsScreen,
    };
    Color selectedColor = theme.accentColor;
    Color unselectedColor = theme.primaryColorDarkest;
    return Container(
      color: theme.primaryColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 0); },
              icon: Icon(
                Icons.all_inclusive,
                size: 30.0,
                color: currTab == 0 ? selectedColor : unselectedColor,
                semanticLabel: 'All Swatches',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 1); },
              icon: Icon(
                Icons.save,
                size: 30.0,
                color: currTab == 1 ? selectedColor : unselectedColor,
                semanticLabel: 'Saved Looks',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 2); },
              icon: Icon(
                Icons.palette,
                size: 30.0,
                color: currTab == 2 ? selectedColor : unselectedColor,
                semanticLabel: 'Color Picker',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 3); },
              icon: Icon(
                Icons.linked_camera,
                size: 30.0,
                color: currTab == 3 ? selectedColor : unselectedColor,
                semanticLabel: 'Palette Scanner',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void routePage(BuildContext context, int page) async {
    if(!menus.containsKey(page)) {
      return;
    }
    Offset pos = Offset(-1.0, 0.0);
    if(page > currTab) {
      pos = Offset(1.0, 0.0);
    }
    if(page != currTab) {
      if(onExit != null) {
        onExit!();
      }
      navigation.pushReplacement(
        context,
        pos,
        menus[page]!,
        routes.enumRoutes[menus[page]]!(context),
      );
    }
  }

  void minusPage(BuildContext context) {
    if(menus.containsKey(currTab - 1)) {
      routePage(context, currTab - 1);
    }
  }

  void plusPage(BuildContext context) {
    if(menus.containsKey(currTab + 1)) {
      routePage(context, currTab + 1);
    }
  }
}