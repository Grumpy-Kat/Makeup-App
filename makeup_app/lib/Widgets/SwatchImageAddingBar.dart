import 'package:GlamKit/Widgets/SwatchImagesAddingLoader.dart';
import 'package:flutter/material.dart';
import '../Data/SwatchImage.dart';

// TODO: test what happens when clicking on SignInButton before SwatchImageAddingBar finishes

class SwatchImageAddingBar {
  final List<SwatchImage> imgs;
  final bool shouldCompress;

  bool isOpen = false;

  List<OverlayEntry> _overlayEntries = [];

  SwatchImageAddingBar(BuildContext context, this.imgs, [ this.shouldCompress = true]) {
    open(context);
  }

  void open(BuildContext context) {
    final Widget overlay = Positioned(
      width: MediaQuery.of(context).size.width - 40,
      height: 55,
      left: 20,
      bottom: 20,
      child: SwatchImagesAddingLoader(
        imgs: imgs,
        shouldCompress: shouldCompress,
        onFinished: close,
      )
    );

    _overlayEntries.add(OverlayEntry(builder: (BuildContext context) => overlay));
    Overlay.of(context)!.insert(_overlayEntries.last);
  }

  void close() {
    for(int i = 0; i < _overlayEntries.length; i++) {
      _overlayEntries[i].remove();
    }

    _overlayEntries = [];
  }
}
