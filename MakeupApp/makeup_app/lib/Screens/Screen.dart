import 'package:flutter/material.dart';
import '../Widgets/SizedSafeArea.dart';
import '../Widgets/MenuBar.dart';
import '../Widgets/CurrSwatchBar.dart';
import '../Widgets/RecommendedSwatchBar.dart';
import '../Widgets/InfoBox.dart';
import '../theme.dart' as theme;

mixin ScreenState {
  Size screenSize;

  Widget buildComplete(BuildContext context, int menu, Widget body, { Widget floatingActionButton }) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: SizedSafeArea(
        builder: (context, screenSize) {
          this.screenSize = screenSize.biggest;
          InfoBox.screenSize = this.screenSize;
          RecommendedSwatchBar.screenSize = this.screenSize;
          return Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MenuBar(menu, onExit),
              ),
              Expanded(
                flex: 8,
                child: body,
              ),
              RecommendedSwatchBar(),
              Expanded(
                flex: 1,
                child: CurrSwatchBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  void onExit() async {}
}
