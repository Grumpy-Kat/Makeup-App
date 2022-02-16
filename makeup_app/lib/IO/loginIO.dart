import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';
import '../globals.dart' as globals;
import 'allSwatchesIO.dart' as allSwatchesIO;
import 'allSwatchesStorageIO.dart' as allSwatchesStorageIO;
import 'savedLooksIO.dart' as savedLooksIO;
import 'settingsIO.dart' as settingsIO;

FirebaseAuth auth = FirebaseAuth.instance;

Future<void> markAllForReload() async {
  allSwatchesIO.hasSaveChanged = true;
  savedLooksIO.hasSaveChanged = true;
  await settingsIO.load();
}

Future<void> signIn([bool setDisplayName = true]) async {
  if(auth.currentUser == null) {
    // If not signed in with some other method previously, sign in anonymously
    await auth.signInAnonymously();
  }

  if(setDisplayName) {
    await auth.currentUser!.updateDisplayName(globals.userID);
  } else {
    String? newUserId = auth.currentUser!.displayName;
    // A valid userId should not contain spaces
    // If it does, its most likely the displayName from a Google account and therefore not a userId
    if(newUserId != null && newUserId != '' && !newUserId.contains(' ')) {
      globals.userID = newUserId;
      allSwatchesStorageIO.init();
    } else {
      await auth.currentUser!.updateDisplayName(globals.userID);
    }
  }

  print(globals.userID);

  auth.currentUser!.getIdToken(true);
}

Future<void> signOut() async {
  // Not actually signing out, just signing in anonymously
  if(auth.currentUser != null) {
    if((await GoogleSignIn().isSignedIn())) {
      // If signed in through google, disconnect in order to not automatically log back in
      try {
        await GoogleSignIn().disconnect();
      } catch(e) {
        print(e);
      }
    }

    await auth.signOut();
    await auth.signInAnonymously();
  }

  String newId = (await FirebaseFirestore.instance.collection('swatches').add({ 'data': '' })).id;
  globals.userID = newId;

  await signIn();
  await settingsIO.save();

  allSwatchesIO.hasSaveChanged = true;
  savedLooksIO.hasSaveChanged = true;
}

Future<void> deleteAccount() async {
  if(auth.currentUser != null) {
    try {
      await auth.currentUser!.delete();
    } catch(e) {
      print(e);
    }
  }

  await settingsIO.clear();
  await allSwatchesIO.clear();
  await allSwatchesStorageIO.deleteAllImgs();
  await savedLooksIO.clearAll();

  // Even though deleteAccount will sign the user out of Firebase, still need to take care of various signOut related operations
  await signOut();

  globals.hasDoneTutorial = true;
  globals.currSwatches.set([]);
}