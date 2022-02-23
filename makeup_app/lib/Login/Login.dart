import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../Data/Swatch.dart';
import '../Data/Look.dart';
import '../Data/SwatchImage.dart';
import '../globals.dart' as globals;

class OriginalAccountData {
  Map<int, Swatch?> swatches = {};
  Map<String, Look> looks = {};
  List<SwatchImage?> swatchImgs = [];

  List<String> tags = [];
  List<String> swatchImgLabels = [];
}

mixin LoginState {
  bool hasFinished = false;

  OriginalAccountData orgAccount = OriginalAccountData();

  Future<void> preserveSaveData() async {
    orgAccount.tags = globals.tags;
    orgAccount.swatchImgLabels = globals.swatchImgLabels;

    // Save original swatches for later use
    if(allSwatchesIO.swatches == null || allSwatchesIO.hasSaveChanged) {
      await allSwatchesIO.loadFormatted();
      orgAccount.swatches = allSwatchesIO.swatches!;
    } else {
      orgAccount.swatches = allSwatchesIO.swatches!;
    }

    // Save original looks for later use
    if(savedLooksIO.looks == null || savedLooksIO.hasSaveChanged) {
      await savedLooksIO.loadFormatted();
      orgAccount.looks = savedLooksIO.looks!;
    } else {
      orgAccount.looks = savedLooksIO.looks!;
    }

    // Save original swatch images for later use
    orgAccount.swatchImgs = [];
    try {
      orgAccount.swatchImgs = await allSwatchesStorageIO.getAllImgs();
      print('orgAccount.swatchImgs ${orgAccount.swatchImgs.length}');
    } catch(e) {
      print('Error retrieving original account swatch images in Login $e');
    }

    hasFinished = false;
  }
}