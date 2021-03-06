import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/Look.dart';
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../globalWidgets.dart' as globalWidgets;
import 'allSwatchesIO.dart' as allSwatchesIO;
import 'savedLooksIO.dart' as savedLooksIO;
import 'settingsIO.dart' as settingsIO;

FirebaseAuth auth = FirebaseAuth.instance;

Future<void> markAllForReload() async {
  allSwatchesIO.hasSaveChanged = true;
  savedLooksIO.hasSaveChanged = true;
  await settingsIO.load();
}

Future<void> combineAccounts(BuildContext context, Map<int, Swatch?> orgAccountSwatches, Map<String, Look> orgAccountLooks) async {
  //clear swatches from today's look to avoid problems
  globals.CurrSwatches.instance.set([]);

  if(auth.currentUser!.displayName ==  null || auth.currentUser!.displayName == '') {
    //new account was just created and has no ID
    await signIn(true);
    return;
  }

  if(orgAccountSwatches.length == 0) {
    //original account has no swatches
    await markAllForReload();
    await signIn(false);
    return;
  }

  //keep copy of old user id
  String oldUserID = globals.userID;
  //transfer user id to new account, may stay this way or may revert to old one
  await signIn(false);
  await markAllForReload();
  await allSwatchesIO.loadFormatted();
  List<Swatch?> newAccountSwatches = allSwatchesIO.swatches!.values.toList();
  if(newAccountSwatches.length == 0) {
    //new account has no swatches
    globals.userID = oldUserID;
    await signIn(true);
    return;
  }

  //if both accounts have swatches, ask user their preference
  await globalWidgets.openDialog(
    context,
    (BuildContext context) {
      return globalWidgets.getAlertDialog(
        context,
        title: Text('Both the local account and the account you are signing into contain swatches. Would you like to combine them or keep the swatches from one account? Warning: Whichever account is not chosen will have its swatches permanently deleted! This can not be undone.', style: theme.primaryTextPrimary),
        actions: <Widget>[
          globalWidgets.getFlatButton(
            bgColor: theme.accentColor,
            onPressed: () async {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);
              await signIn(false);
              List<int> newIds = await allSwatchesIO.add(orgAccountSwatches.values.toList());
              if(orgAccountLooks.length != 0) {
                List<int> oldIds = orgAccountSwatches.keys.toList();
                Map<int, int> idToId = {};
                //old and new ids might be different length if any swatches are null
                int newI = 0;
                //create map that converts the swatches old ids to their new ids
                for(int i = 0; i < orgAccountSwatches.length; i++) {
                  if(orgAccountSwatches[oldIds[i]] != null) {
                    idToId[oldIds[i]] = newIds[newI];
                    print('$i ${oldIds[i]} $newI ${newIds[newI]}');
                  }
                  newI++;
                }

                //change ids in looks
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
              }
              Navigator.pop(context);
            },
            child: Text(
              'Combine',
              style: theme.accentTextBold,
            ),
          ),
          globalWidgets.getFlatButton(
            bgColor: theme.accentColor,
            onPressed: () async {
              Navigator.pop(context);
              globalWidgets.openLoadingDialog(context);
              //use original account
              globals.userID = oldUserID;
              await signIn(true);
              allSwatchesIO.hasSaveChanged = true;
              savedLooksIO.hasSaveChanged = true;
              await allSwatchesIO.loadFormatted();
              await savedLooksIO.loadFormatted();
              Navigator.pop(context);
            },
            child: Text(
              'Local Account',
              style: theme.accentTextBold,
            ),
          ),
          globalWidgets.getFlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              Navigator.pop(context);
              //use new account
              signIn(false);
            },
            child: Text(
              'New Account',
              style: theme.accentTextBold,
            ),
          ),
        ],
      );
    },
  );
}

Future<void> signIn([bool setDisplayName = true]) async {
  if(auth.currentUser == null) {
    //if not signed in with some other method previously, sign in anonymously
    await auth.signInAnonymously();
  }
  if(setDisplayName) {
    await auth.currentUser!.updateProfile(displayName: globals.userID);
  } else {
    String? newUserId = auth.currentUser!.displayName;
    if(newUserId != null && newUserId != '') {
      globals.userID = newUserId;
    }
  }
  auth.currentUser!.getIdToken(true);
}

Future<void> signOut() async {
  //not actually signing out, just signing in anonymously
  await auth.signOut();
  await auth.signInAnonymously();
  String newId = (await FirebaseFirestore.instance.collection('swatches').add({ 'data': '' })).id;
  globals.userID = newId;
  await signIn();
  await settingsIO.save();
  allSwatchesIO.hasSaveChanged = true;
  savedLooksIO.hasSaveChanged = true;
}