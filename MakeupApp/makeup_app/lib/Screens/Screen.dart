import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
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

  Widget buildComplete(BuildContext context, String title, int menu, { @required Widget body, Widget leftBar, List<Widget> rightBar, Widget floatingActionButton }) {
    Widget child = SizedSafeArea(
      builder: (context, screenSize) {
        this.screenSize = screenSize.biggest;
        InfoBox.screenSize = this.screenSize;
        RecommendedSwatchBar.screenSize = this.screenSize;
        return Column(
          children: <Widget>[
            //top bar, including menu button, right bar, left bar, and title, takes up top 10%
            Expanded(
              flex: 1,
              child: Container(
                color: theme.primaryColor,
                child: Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
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
                          if(leftBar != null) leftBar,
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 2, right: 2, top: 3),
                        child: AutoSizeText(
                          title,
                          style: theme.primaryTextBold,
                          minFontSize: 11,
                          maxFontSize: theme.primaryTextBold.fontSize,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: rightBar ?? [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //body is determined by screen subclassing, takes up middle 80%
            Expanded(
              flex: 8,
              child: body,
            ),
            //RecommendedSwatchBar takes up no space, just placeholder
            RecommendedSwatchBar(key: recommendedSwatchBarKey),
            //CurrSwatchBar takes up bottom 10%
            Expanded(
              flex: 1,
              child: CurrSwatchBar(),
            ),
          ],
        );
      },
    );
    /*Widget appBar = AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: (leftBar == null ? (theme.primaryIconSize * 2) + 5 : (theme.primaryIconSize * 4) + 5),
      leading: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
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
            if(leftBar != null) leftBar,
          ],
        ),
      ),
      title: Text(title, style: theme.primaryTextBold),
      actions: rightBar,
    );*/
    return Scaffold(
      key: scaffoldKey,
      drawer: NavigationDrawer(key: menuKey, currTab: menu, onExit: onExit),
      backgroundColor: theme.bgColor,
      //floatingActionButton is determined by screen subclassing
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }

  void onExit() async {
    //closes RecommendedSwatchBar manually, to prevent bugs
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
