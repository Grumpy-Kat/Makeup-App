import 'package:flutter/material.dart';
import 'globalWidgets.dart' as globalWidgets;
import 'routes.dart' as routes;

List<routes.ScreenRoutes> _history = [];

void init(routes.ScreenRoutes nextScreenEnum) {
  _history.clear();
  _history.add(nextScreenEnum);
}

void pushReplacement(BuildContext context, Offset offset, routes.ScreenRoutes nextScreenEnum, Widget nextScreen) {
  if(_history.length > 0) {
    _history[_history.length - 1] = nextScreenEnum;
  } else {
    _history.add(nextScreenEnum);
  }
  Navigator.pushReplacement(
    context,
    globalWidgets.slideTransition(
      context,
      nextScreen,
      350,
      offset,
      Offset.zero,
    ),
  );
}

void push(BuildContext context, Offset offset, routes.ScreenRoutes nextScreenEnum, Widget nextScreen) {
  _history.add(nextScreenEnum);
  Navigator.push(
    context,
    globalWidgets.slideTransition(
      context,
      nextScreen,
      350,
      offset,
      Offset.zero,
    ),
  );
}

void pop(BuildContext context, bool reloadPrev) {
  if(_history.length <= 1) {
    push(context, Offset(-1, 0), routes.defaultEnumRoute, routes.routes[routes.defaultRoute](context));
    return;
  }
  _history.removeLast();
  if(_history.length > 1 && _history[_history.length - 1] == _history[_history.length - 2]) {
    _history.removeLast();
  }
  routes.ScreenRoutes prevScreen = _history[_history.length - 1];
  Navigator.pushReplacement(
    context,
    globalWidgets.slideTransition(
      context,
      routes.enumRoutes[prevScreen](context),
      350,
      Offset(-1, 0),
      Offset.zero,
    ),
  );
}