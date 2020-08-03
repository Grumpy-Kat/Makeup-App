import 'package:flutter/material.dart';
import '../Widgets/SizedSafeArea.dart';
import '../Widgets/MenuBar.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/CurrSwatchBar.dart';
import '../Widgets/RecommendedSwatchBar.dart';
import '../Widgets/InfoBox.dart';
import '../theme.dart' as theme;
import '../routes.dart' as routes;

mixin ScreenState {
  Widget buildComplete(BuildContext context, Future<List<Swatch>> Function() loadFormatted, int menu, Widget body) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      body: SizedSafeArea(
        builder: (context, screenSize) {
          InfoBox.screenSize = screenSize.biggest;
          return Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MenuBar(menu),
              ),
              Expanded(
                flex: 8,
                child: body,
              ),
              RecommendedSwatchBar(loadFormatted),
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
}
