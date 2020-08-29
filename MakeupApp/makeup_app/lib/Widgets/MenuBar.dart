import 'package:flutter/material.dart';
import '../types.dart';
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;

class MenuBar extends StatelessWidget {
  final int currTab;
  final OnVoidAction onExit;

  MenuBar(this.currTab, this.onExit);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.primaryColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 0, routes.ScreenRoutes.Main0Screen); },
              icon: Icon(
                Icons.all_inclusive,
                size: 30.0,
                color: currTab == 0 ? theme.accentColor : theme.primaryTextColor,
                semanticLabel: 'All Colors',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 1, routes.ScreenRoutes.Main1Screen); },
              icon: Icon(
                Icons.palette,
                size: 30.0,
                color: currTab == 1 ? theme.accentColor : theme.primaryTextColor,
                semanticLabel: 'Color Picker',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 2, routes.ScreenRoutes.Main2Screen); },
              icon: Icon(
                Icons.linked_camera,
                size: 30.0,
                color: currTab == 2 ? theme.accentColor : theme.primaryTextColor,
                semanticLabel: 'Palette Scanner',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 3, routes.ScreenRoutes.Main3Screen); },
              icon: Icon(
                Icons.style,
                size: 30.0,
                color: currTab == 3 ? theme.accentColor : theme.primaryTextColor,
                semanticLabel: 'Lookbook',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void routePage(BuildContext context, int page, routes.ScreenRoutes pageEnum) async {
    Offset pos = Offset(-1.0, 0.0);
    if(page > currTab) {
      pos = Offset(1.0, 0.0);
    }
    if(page != currTab) {
      await onExit();
      navigation.pushReplacement(
        context,
        pos,
        pageEnum,
        routes.routes['/main${page}Screen'](context),
      );
    }
  }
}