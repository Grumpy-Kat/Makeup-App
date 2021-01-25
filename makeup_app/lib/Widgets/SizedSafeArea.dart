import 'package:flutter/material.dart';

class SizedSafeArea extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints screenSize) builder;

  SizedSafeArea({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, screenSize) {
          return builder(context, screenSize);
        }
      ),
    );
  }
}