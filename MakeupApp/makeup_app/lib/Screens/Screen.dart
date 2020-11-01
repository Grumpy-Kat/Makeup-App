import 'package:flutter/material.dart';
import 'dart:math';
import '../Widgets/SizedSafeArea.dart';
import '../Widgets/MenuBar.dart';
import '../Widgets/CurrSwatchBar.dart';
import '../Widgets/RecommendedSwatchBar.dart';
import '../Widgets/InfoBox.dart';
import '../theme.dart' as theme;

mixin ScreenState {
  Size screenSize;

  List<Rectangle<double>> noScreenSwipes = List<Rectangle<double>>();

  GlobalKey menuKey = GlobalKey();
  GlobalKey recommendedSwatchBarKey = GlobalKey();

  bool isDragging = false;

  Widget buildComplete(BuildContext context, int menu, Widget body, { Widget floatingActionButton, bool includeHorizontalDragging = true }) {
    Widget child = SizedSafeArea(
      builder: (context, screenSize) {
        this.screenSize = screenSize.biggest;
        InfoBox.screenSize = this.screenSize;
        RecommendedSwatchBar.screenSize = this.screenSize;
        return Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: MenuBar(key: menuKey, currTab: menu, onExit: onExit),
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
      backgroundColor: theme.bgColor,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: includeHorizontalDragging ? GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onHorizontalDragStart: (DragStartDetails drag) { onHorizontalDragStart(context, drag); },
        onHorizontalDragEnd: (DragEndDetails drag) { onHorizontalDragEnd(context, drag); },
        child: child,
      ) : child,
    );
  }

  void onExit() async {
    (recommendedSwatchBarKey.currentState as RecommendedSwatchBarState).close();
  }

  void onHorizontalDragStart(BuildContext context, DragStartDetails drag) {
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
  }
}
