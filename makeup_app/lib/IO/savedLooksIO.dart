import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Data/Look.dart';
import 'globalIO.dart';
import 'allSwatchesIO.dart' as allSwatches;
import '../globals.dart' as globals;

List<DocumentSnapshot>? docs;
Map<String, Look>? looks;
bool hasSaveChanged = true;

late CollectionReference _database;

Future<void> init() async {
  allSwatches.listenOnSaveChanged(() {
    loadFormatted(override: true);
  });
  _database = FirebaseFirestore.instance.collection('looks');
}

Future<void> clear(String id) async {
  hasSaveChanged = true;
  print('Clearing $id');
  DocumentSnapshot doc = await _database.doc(id).get();
  await doc.reference.delete();
}

Future<void> clearAll() async {
  hasSaveChanged = true;
  List<QueryDocumentSnapshot> allDocs = (await _database.where('user', isEqualTo: globals.userID).get()).docs;
  for(int i = 0; i < allDocs.length; i++) {
    await allDocs[i].reference.delete();
  }
}

Future<String> save(Look look) async  {
  print('save ${look.id}');
  hasSaveChanged = true;
  //clean name input
  look.name = removeAllChars(look.name, [r'\\']);
  if(look.name == '') {
    look.name = 'Look';
  }
  if(look.id == '') {
    //adding look for the first time
    look.id = (await _database.add(
      {
        'name': look.name,
        'swatches': look.swatches,
        'user': globals.userID,
      }
    )).id;
  } else {
    //updating look
    await _database.doc(look.id).set(
        {
          'name': look.name,
          'swatches': look.swatches,
          'user': globals.userID,
        }
    );
  }
  return look.id;
}

Future<List<DocumentSnapshot>> load({ bool override = false }) async {
  if(docs == null || hasSaveChanged || override) {
    docs = (await _database.where('user', isEqualTo: globals.userID).get()).docs;
  }
  return docs!;
}

Future<Map<String, Look>> loadFormatted({ bool override = false, overrideInner = false }) async {
  if(looks == null || hasSaveChanged || override || overrideInner) {
    looks = {};
    List<DocumentSnapshot> info = await load(override: overrideInner);
    for(int i = 0; i < info.length; i++) {
      List<int> swatches = List.from(info[i].get('swatches'));
      for(int j = swatches.length - 1; j >= 0; j--) {
        if(!allSwatches.isValid(swatches[j])) {
          swatches.removeAt(j);
        }
      }
      if(swatches.length > 0) {
        swatches = await allSwatches.sort(swatches, (a, b) => a.compareTo(b, (swatch) => globals.defaultSortOptions([allSwatches.getMany(swatches)])[globals.sort]!(swatch, 0)));
        //contains swatches
        looks![info[i].id] = Look(
          id: info[i].id,
          name: info[i].get('name'),
          swatches: swatches,
        );
      }
    }
    print('${looks!.length} looks');
    hasSaveChanged = false;
  }
  return looks!;
}