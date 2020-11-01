import 'package:flutter/material.dart';
import 'dart:math';
import '../Widgets/SizedSafeArea.dart';
import '../Widgets/NavigationDrawer.dart';
import '../Widgets/CurrSwatchBar.dart';
import '../Widgets/RecommendedSwatchBar.dart';
import '../Widgets/InfoBox.dart';
import '../theme.dart' as theme;

mixin ScreenState {
  Size screenSize;

  List<Rectangle<double>> noScreenSwipes = List<Rectangle<double>>();

  GlobalKey scaffoldKey = GlobalKey();
  GlobalKey menuKey = GlobalKey();
  GlobalKey recommendedSwatchBarKey = GlobalKey();

  bool isDragging = false;

  Widget buildComplete(BuildContext context, String title, int menu, List<Widget> bar, Widget body, { Widget floatingActionButton }) {
    Widget child = SizedSafeArea(
      builder: (context, screenSize) {
        this.screenSize = screenSize.biggest;
        InfoBox.screenSize = this.screenSize;
        RecommendedSwatchBar.screenSize = this.screenSize;
        return Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: theme.primaryIconSize,
                        color: theme.iconTextColor,
                        semanticLabel: 'Menu',
                      ),
                      onPressed: () {
                        (scaffoldKey.currentState as ScaffoldState).openDrawer();
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 7, right: 7, top: 3),
                    child: Text(title, style: theme.primaryTextBold),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: bar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: body,
            ),
            RecommendedSwatchBar(key: recommendedSwatchBarKey),
            Expanded(
              flex: 1,
              child: CurrSwatchBar(),
            ),
          ],
        );
      },
    );
    return Scaffold(
      key: scaffoldKey,
      drawer: NavigationDrawer(key: menuKey, currTab: menu, onExit: onExit),
      backgroundColor: theme.bgColor,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }

  void onExit() async {
    (recommendedSwatchBarKey.currentState as RecommendedSwatchBarState).close();
  }

  /*void onHorizontalDragStart(BuildContext context, DragStartDetails drag) {
    isDragging = true;
    print(drag.globalPosition);
    for(int i = 0; i < noScreenSwipes.length; i++) {
      if(noScreenSwipes[i].containsPoint(Point<double>(drag.globalPosition.dx, drag.globalPosition.dy))) {
        isDragging = false;
      }
    }
  }

  void onHorizontalDragEnd(BuildContext context, DragEndDetails drag) {
    double threshold = 0.001;
    isDragging = false;
    if(drag.primaryVelocity < -threshold) {
      (menuKey.currentWidget as MenuBar).plusPage(context);
    } else if(drag.primaryVelocity > threshold) {
      (menuKey.currentWidget as MenuBar).minusPage(context);
    }
  }*/
}
