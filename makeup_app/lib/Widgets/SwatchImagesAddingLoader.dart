import 'package:flutter/material.dart';
import '../Data/SwatchImage.dart';
import '../IO/allSwatchesStorageIO.dart' as IO;
import '../theme.dart' as theme;
import '../types.dart';

class SwatchImagesAddingLoader extends StatefulWidget {
  final List<SwatchImage> imgs;
  final bool shouldCompress;

  final OnVoidAction onFinished;

  SwatchImagesAddingLoader({ required this.imgs, this.shouldCompress = true, required this.onFinished });

  @override
  _SwatchImagesAddingLoaderState createState() => _SwatchImagesAddingLoaderState();
}

class _SwatchImagesAddingLoaderState extends State<SwatchImagesAddingLoader> {
  int currentSavingIndex = 0;

  @override
  void initState() {
    super.initState();

    _saveImages();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColorLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, -3),
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Text(
            'Saved $currentSavingIndex out ${widget. imgs.length} images: ',
            style: theme.primaryTextSecondary,
          ),

          SizedBox(
            width: 20,
          ),

          Expanded(
            child: LinearProgressIndicator(
              value: currentSavingIndex / widget.imgs.length.toDouble(),
              backgroundColor: theme.primaryColorDark,
              color: theme.accentColor,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImages() async {
    for(; currentSavingIndex < widget.imgs.length; currentSavingIndex++) {
      // Using updateImg to specifically set id
      await IO.updateImg(swatchImg: widget.imgs[currentSavingIndex], shouldCompress: widget.shouldCompress);

      setState(() { });
    }

    widget.onFinished();
  }
}
