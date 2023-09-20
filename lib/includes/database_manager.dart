import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:feelingapp/includes/user.dart';

class DatabaseManager {
  final db = FirebaseFirestore.instance;
  final userCollection = "users";
  final likedCollection = "likes";
  final sawCollection = "saw";
  final settingsCollection = "settings";
  final behaviorCollection = "behavior";
  final linksCollection = "links";

  Future<Map> getCurrentUserDocument(String uid) async {
    var snapshot = await db.collection(userCollection).doc(uid).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  Future<Map> getOtherUserDocument(String uid) async {
    final HttpsCallable personalizedVideos =
        FirebaseFunctions.instanceFor(region: "europe-west1")
            .httpsCallable("get_data_by_uid");

    HttpsCallableResult res = await personalizedVideos.call({"uid": uid});
    return res.data['data'];
  }

  Future<bool> createNewUser(String uid, String promoCode) async {
    bool userExists = await getCurrentUserDocument(uid) == null ? false : true;
    var data = AppUser().toEmptyMap();
    data['uid'] = uid;

    if (promoCode != null && promoCode.length == 6) {
      data['inviteCode'] = promoCode;
    } else {
      data['inviteCode'] = "";
    }
    if (!userExists) {
      db.collection(userCollection).doc(uid).set(data).then((_) {
        print("success!");
      });
    }
    return true;
  }

  Future<void> updateUserDetails(String uid, Map<String, dynamic> data) {
    return db.collection(userCollection).doc(uid).update(data);
  }

  Future<DocumentReference> updateUserLiked(String myUid, String otherUid) {
    return db
        .collection(userCollection)
        .doc(myUid)
        .collection(likedCollection)
        .add({'uid': otherUid, 'date': Timestamp.now()});
  }

  Future<QuerySnapshot> getUserLiked(String myUid, String otherUid) {
    return db
        .collection(userCollection)
        .doc(myUid)
        .collection(likedCollection)
        .where('uid', isEqualTo: otherUid)
        .get();
  }

  Future<DocumentReference> updateUserSeen(String myUid, String otherUid) {
    return db
        .collection(userCollection)
        .doc(myUid)
        .collection(sawCollection)
        .add({'uid': otherUid, 'date': Timestamp.now()});
  }

  Future<QuerySnapshot> getUserSeen(String myUid, String otherUid) {
    return db
        .collection(userCollection)
        .doc(myUid)
        .collection(sawCollection)
        .where('uid', isEqualTo: otherUid)
        .get();
  }

  Future<DocumentSnapshot> loadLinks() {
    return db.collection(settingsCollection).doc(linksCollection).get();
  }

  Future<DocumentSnapshot> loadBehavior() {
    return db.collection(settingsCollection).doc(behaviorCollection).get();
  }
}
