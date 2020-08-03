import 'package:flutter/material.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;

class MenuBar extends StatelessWidget {
  final int currTab;

  MenuBar(this.currTab);

  @override
  Widget build(BuildContext context) {
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
                color: currTab == 0 ? theme.accentColor : theme.primaryTextColor,
                semanticLabel: 'All Colors',
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              color: theme.primaryColor,
              onPressed: () { routePage(context, 1); },
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
              onPressed: () { routePage(context, 2); },
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
              onPressed: () { routePage(context, 3); },
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

  void routePage(BuildContext context, int page) {
    Offset pos = Offset(-1.0, 0.0);
    if(page > currTab) {
      pos = Offset(1.0, 0.0);
    }
    if(page != currTab) {
      Navigator.pushReplacement(context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1500),
          pageBuilder: (context, animation, secondaryAnimation) { return routes.routes['/main${page}Screen'](context); },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween(
                begin: pos,
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCirc,
                ),
              ),
              child: child,
            );
          },
        ),
      );
    }
  }
}