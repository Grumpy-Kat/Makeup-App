import 'package:flutter/material.dart' hide FlatButton;
import '../Data/Swatch.dart';
import '../Data/Look.dart';
import '../Data/SwatchImage.dart';
import '../Widgets/FlatButton.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import 'localizationIO.dart';
import 'loginIO.dart';
import 'allSwatchesIO.dart' as allSwatchesIO;
import 'allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import 'savedLooksIO.dart' as savedLooksIO;

Future<void> combineAccounts(BuildContext context, Map<int, Swatch?> orgAccountSwatches, Map<String, Look> orgAccountLooks, List<SwatchImage> orgAccountSwatchImgs) async {
  // Clear swatches from today's look to avoid problems
  globals.CurrSwatches.instance.set([]);

  if(auth.currentUser!.displayName ==  null || auth.currentUser!.displayName == '') {
    await _newAccount();
    return;
  }

  if(orgAccountSwatches.length == 0) {
    await _oldNoSwatches();
    return;
  }

  // Keep copy of old user id
  String oldUserID = globals.userID;
  // Transfer user id to new account, may stay this way or may revert to old one
  await signIn(false);
  await markAllForReload();
  await allSwatchesIO.loadFormatted();

  // Check if new account has swatches
  if(allSwatchesIO.swatches!.values.toList().length == 0) {
    await _newNoSwatches(oldUserID);
    return;
  }

  await _bothAccounts(context, oldUserID, orgAccountSwatches, orgAccountLooks, orgAccountSwatchImgs);
}

Future<void> _newAccount() async {
  // New account was just created and has no ID
  await signIn(true);
}

Future<void> _oldNoSwatches() async {
  // Original account has no swatches
  await markAllForReload();
  await signIn(false);
}

Future<void> _newNoSwatches(String oldUserID) async {
  // New account has no swatches
  globals.userID = oldUserID;
  await signIn(true);
}

Future<void> _bothAccounts(BuildContext context, String oldUserID, Map<int, Swatch?> orgAccountSwatches, Map<String, Look> orgAccountLooks, List<SwatchImage> orgAccountSwatchImgs) async {
  // If both accounts have swatches, ask user their preference
  await globalWidgets.openDialog(
    context,
        (BuildContext context) {
      return globalWidgets.getAlertDialog(
        context,
        title: Text(
          getString('login_popupInstructions'),
          style: theme.primaryTextPrimary,
        ),
        actions: <Widget>[
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () async {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);

              await _bothCombineAccounts(orgAccountSwatches, orgAccountLooks, orgAccountSwatchImgs);

              Navigator.pop(context);
            },
            child: Text(
              getString('login_combine'),
              style: theme.accentTextBold,
            ),
          ),
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () async {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);

              await _bothOldAccount(oldUserID);

              Navigator.pop(context);
            },
            child: Text(
              getString('login_local'),
              style: theme.accentTextBold,
            ),
          ),
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () async {
              Navigator.pop(context);

              await _bothNewAccount();
            },
            child: Text(
              getString('login_new'),
              style: theme.accentTextBold,
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _bothCombineAccounts(Map<int, Swatch?> orgAccountSwatches, Map<String, Look> orgAccountLooks, List<SwatchImage> orgAccountSwatchImgs) async {
  await signIn(false);
  List<int> newIds = await allSwatchesIO.add(orgAccountSwatches.values.toList());
  if(orgAccountLooks.length != 0) {
    List<int> oldIds = orgAccountSwatches.keys.toList();
    Map<int, int> idToId = {};
    // Old and new ids might be different length if any swatches are null
    int newI = 0;
    // Create map that converts the swatches old ids to their new ids
    for(int i = 0; i < orgAccountSwatches.length; i++) {
      if(orgAccountSwatches[oldIds[i]] != null) {
        idToId[oldIds[i]] = newIds[newI];
        print('$i ${oldIds[i]} $newI ${newIds[newI]}');
      }
      newI++;
    }

    // Change ids in looks and save the new ones
    List<Look> oldLooks = orgAccountLooks.values.toList();
    for(int i = 0; i < oldLooks.length; i++) {
      List<int> swatches = oldLooks[i].swatches;
      for(int j = 0; j < swatches.length; j++) {
        swatches[j] = idToId[swatches[j]] ?? -1;
      }
      print(swatches);

      oldLooks[i].swatches = swatches;
      oldLooks[i].id = '';

      await savedLooksIO.save(oldLooks[i]);
    }

    // Change ids in swatchImgs and save the new ones
    for(int i = 0; i < orgAccountSwatchImgs.length; i++) {
      SwatchImage swatchImg = orgAccountSwatchImgs[i];
      int newSwatchId = idToId[swatchImg.swatchId] ?? -1;

      if(newSwatchId != -1) {
        await allSwatchesStorageIO.updateImg(
          swatchImg: SwatchImage(
            swatchId: newSwatchId,
            id: swatchImg.id,
            width: swatchImg.width,
            height: swatchImg.height,
            bytes: swatchImg.bytes,
            labels: swatchImg.labels,
          ),
        );
      }
    }
  }
}

Future<void> _bothOldAccount(String oldUserID) async {
  // Use original account
  globals.userID = oldUserID;

  await signIn(true);

  allSwatchesIO.hasSaveChanged = true;
  savedLooksIO.hasSaveChanged = true;

  await allSwatchesIO.loadFormatted();
  await savedLooksIO.loadFormatted();
}

Future<void> _bothNewAccount() async {
  // Use new account
  await signIn(false);
}