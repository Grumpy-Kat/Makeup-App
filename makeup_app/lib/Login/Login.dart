import '../IO/allSwatchesIO.dart' as allSwatchesIO;
import '../IO/savedLooksIO.dart' as savedLooksIO;
import '../IO/allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import '../Data/Swatch.dart';
import '../Data/Look.dart';
import '../Data/SwatchImage.dart';

mixin LoginState {
  late Map<int, Swatch?> orgAccountSwatches;
  late Map<String, Look> orgAccountLooks;
  late List<SwatchImage> orgAccountSwatchImgs;

  void preserveSaveData() {
    // Save original swatches for later use
    if(allSwatchesIO.swatches == null || allSwatchesIO.hasSaveChanged) {
      allSwatchesIO.loadFormatted().then(
        (value) {
          orgAccountSwatches = allSwatchesIO.swatches!;
        }
      );
    } else {
      orgAccountSwatches = allSwatchesIO.swatches!;
    }

    // Save original looks for later use
    if(savedLooksIO.looks == null || savedLooksIO.hasSaveChanged) {
      savedLooksIO.loadFormatted().then(
        (value) {
          orgAccountLooks = savedLooksIO.looks!;
        }
      );
    } else {
      orgAccountLooks = savedLooksIO.looks!;
    }

    // Save original swatch images for later use
    allSwatchesStorageIO.getAllImgs().then(
      (value) {
        orgAccountSwatchImgs = value;
      }
    );
  }
}