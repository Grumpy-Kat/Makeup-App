import 'package:flutter/material.dart' hide FlatButton;
import '../Data/Look.dart';
import '../Data/SwatchImage.dart';
import '../Login/Login.dart';
import '../Widgets/FlatButton.dart';
import '../Widgets/SwatchImageAddingBar.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import 'localizationIO.dart';
import 'loginIO.dart';
import 'allSwatchesIO.dart' as allSwatchesIO;
import 'savedLooksIO.dart' as savedLooksIO;

Future<void> combineAccounts(BuildContext context, OriginalAccountData orgAccount) async {
  // Clear swatches from today's look to avoid problems
  globals.CurrSwatches.instance.set([]);

  if(auth.currentUser!.displayName == null || auth.currentUser!.displayName == '') {
    await _newAccount();
    return;
  }

  if(orgAccount.swatches.length == 0) {
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

  await _bothAccounts(context, oldUserID, orgAccount);
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

Future<void> _bothAccounts(BuildContext context, String oldUserID, OriginalAccountData orgAccount) async {
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
            onPressed: () {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);

              _bothCombineAccounts(context, orgAccount).then(
                    (val) {
                  Navigator.pop(context);
                },
              );
            },
            child: Text(
              getString('login_combine'),
              style: theme.accentTextBold,
            ),
          ),
          FlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);

              _bothOldAccount(oldUserID).then(
                (val) {
                  Navigator.pop(context);
                },
              );
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
    barrierDismissible: false,
  );
}

Future<void> _bothCombineAccounts(BuildContext context, OriginalAccountData orgAccount) async {
  await signIn(false);
  List<int> newIds = await allSwatchesIO.add(orgAccount.swatches.values.toList());
  if(orgAccount.looks.length != 0 || orgAccount.swatchImgs.length != 0) {
    globals.tags = (globals.tags + orgAccount.tags).toSet().toList();
    globals.swatchImgLabels = (globals.swatchImgLabels + orgAccount.swatchImgLabels).toSet().toList();

    List<int> oldIds = orgAccount.swatches.keys.toList();
    Map<int, int> idToId = {};
    // Old and new ids might be different length if any swatches are null
    int newI = 0;
    // Create map that converts the swatches old ids to their new ids
    for(int i = 0; i < orgAccount.swatches.length; i++) {
      if(orgAccount.swatches[oldIds[i]] != null) {
        idToId[oldIds[i]] = newIds[newI];
        print('$i ${oldIds[i]} $newI ${newIds[newI]}');
      }
      newI++;
    }

    // Change ids in looks and save the new ones
    List<Look> oldLooks = orgAccount.looks.values.toList();
    await Future.wait(
      oldLooks.map(
        (Look look) async {
          List<int> swatches = look.swatches;
          for (int j = 0; j < swatches.length; j++) {
            swatches[j] = idToId[swatches[j]] ?? -1;
          }
          look.swatches = swatches;
          look.id = '';
          await savedLooksIO.save(look);
        }
      ),
    );

    print('_bothCombineAccounts length ${orgAccount.swatchImgs.length}');
    // Change ids in swatchImgs and save the new ones
    List<SwatchImage?> oldSwatchImgs = orgAccount.swatchImgs;
    List<SwatchImage> swatchImgsToAdd = [];
    oldSwatchImgs.map(
      (SwatchImage? swatchImg) async {
        if(swatchImg != null) {
          int newSwatchId = idToId[swatchImg.swatchId] ?? -1;
          if(newSwatchId != -1) {
            swatchImgsToAdd.add(
              SwatchImage(
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
    );
    SwatchImageAddingBar(context, swatchImgsToAdd);
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