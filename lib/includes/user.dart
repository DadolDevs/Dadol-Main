import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:feelingapp/includes/reward/reward.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/views/profile/widgets/tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:image_editor/image_editor.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumbnail;
import 'dart:convert';

enum RegistrationStage {
  REGISTERED_BUT_MISSING_DATA, // Did not check the box etc...
  REGSITERED_WITHOUT_THE_TUTORIAL,
  COMPLETE
}

class AppUser {
  String uid;
  String userName;
  int gender;
  int genderPreference;
  String mediaUrl;
  String mainTag;
  List<dynamic> additionalTags;
  String userVideoThumbnail;
  Timestamp lastLogin;
  Timestamp birthDate;
  bool verified;
  var userSettings;
  String accountState;
  String couponState;
  int numberOfVideosViewedToday = 0;
  bool tagsCoachShown = false;
  String promoCode;
  String rewardMail;
  Reward reward;

  var registrationStage;
  String get username => userName;
  List<String> userTagSearchFilter = [];

  var lastServerTimestamp = Timestamp.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> tagAttributes;
  Map<String, dynamic> tagInterests;

  AppUser();

  AppUser.map(dynamic obj) {
    this.uid = obj["uid"];
    this.userName = obj["userName"];
    this.gender = obj["gender"];
    this.genderPreference = obj["genderPreference"];
    this.mainTag = obj["mainTag"];
    this.additionalTags = obj["additionalTags"];
    this.lastLogin = obj["lastLogin"];
    this.birthDate = obj["birthDate"];
    this.registrationStage = obj["registrationStage"];
    this.verified = obj["verified"];
    this.accountState = obj["accountState"];
    this.couponState = obj["couponState"] ?? "Initial";
    this.numberOfVideosViewedToday = obj["numberOfVideosViewedToday"];
    this.tagsCoachShown = obj["tagsCoachShown"];
    this.rewardMail = obj["rewardMail"];
    this.promoCode = obj["promoCode"] ?? "";
    this.reward = obj['reward'] != null ? Reward.fromMap(obj['reward']) : null;

    getCurrentRewardSettings();
  }

  Future<void> loadUserSettings(preferredLocale) async {
    if (uid == null) {
      throw Exception(
          "Cannot load user settings without first loading the user");
    }

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("userSettings")
        .doc("clientSettings")
        .get();

    userSettings = snapshot.data();

    if (userSettings == null) {
      userSettings = {
        "matchPushNotifications": true,
        "messagePushNotifications": true,
        "otherPushNotifications": true,
        "preferredLocale": preferredLocale,
        "loginType": "",
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection("userSettings")
          .doc("clientSettings")
          .set(userSettings);
    }

    snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("userSettings")
        .doc("socialAuth")
        .get();

    if (snapshot.exists == false) {
      userSettings['loginType'] = "";
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection("userSettings")
          .doc("socialAuth")
          .set({"google": false, "facebook": false});
      userSettings['socialAuth'] = {"google": false, "facebook": false};
    } else {
      userSettings['socialAuth'] = snapshot.data();
    }
    return;
  }

  Future<void> loadMediaUrls() async {
    try {
      this.mediaUrl = await FirebaseStorage.instance
          .ref()
          .child("user_videos")
          .child(currentUser.uid)
          .getDownloadURL();
      this.userVideoThumbnail = await FirebaseStorage.instance
          .ref()
          .child("userVideoThumbnail")
          .child(currentUser.uid)
          .getDownloadURL();

      if (accountState == "ActiveWithVideo") {
        await dbManager.updateUserDetails(uid, {"firstVideoAccepted": true});
      }
    } catch (e) {
      debugPrint("User does not have any video/thumbnail");
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["uid"] = uid;
    map["userName"] = userName;
    map["gender"] = gender;
    map["genderPreference"] = genderPreference;
    map["mediaUrl"] = mediaUrl;
    map["mainTag"] = mainTag;
    map["additionalTags"] = additionalTags;
    map["user_video_thumbnail"] = userVideoThumbnail;
    map["lastLogin"] = lastLogin;
    map["birthDate"] = birthDate;
    map["registrationStage"] = registrationStage;
    map["verified"] = verified;
    map["numberOfVideosViewedToday"] = numberOfVideosViewedToday;
    map["tagsCoachShown"] = tagsCoachShown;
    map["promoCode"] = promoCode;
    return map;
  }

  Map<String, dynamic> toEmptyMap() {
    var map = new Map<String, dynamic>();
    map["uid"] = "";
    map["userName"] = "";
    map["gender"] = 0;
    map["genderPreference"] = 0;
    map["mediaUrl"] = "";
    map["additionalTags"] = [];
    map["user_video_thumbnail"] = "";
    map["lastLogin"] = Timestamp.fromMillisecondsSinceEpoch(0);
    map["birthDate"] = Timestamp.fromMillisecondsSinceEpoch(0);
    map["registrationStage"] =
        RegistrationStage.REGISTERED_BUT_MISSING_DATA.index;
    map["accountState"] = "Active";
    map["couponState"] = "Initial";
    map["numberOfVideosViewedToday"] = 0;
    map["tagsCoachShown"] = false;
    map["promoCode"] = "";
    return map;
  }

  Future<String> getVideoByName(String fileName) async {
    final Reference ref =
        FirebaseStorage.instance.ref().child('user_videos').child(fileName);
    return await ref.getDownloadURL();
  }

  Future<void> getCurrentRewardSettings() async {
    final ref = await FirebaseFirestore.instance
        .collection("settings")
        .doc("reward")
        .get();

    Reward tmpReward = Reward.fromMap(ref.data());

    if (reward == null) {
    reward = tmpReward;
    }  else{
      reward.subscriptionReward = tmpReward.subscriptionReward;
      reward.inviteReward = tmpReward.inviteReward;
    }
    await dbManager.updateUserDetails(uid, {"reward": reward.toJson()});
    await getSpecials();
  }

  Future<void> getSpecials() async {
    final ref = await FirebaseFirestore.instance
        .collection("settings")
        .doc("reward")
        .collection("specials")
        .get();

    reward.specials = ref.docs.length > 0
        ? ref.docs.map<SpecialReward>((cap) {
            return SpecialReward.fromMap(cap.data());
          }).toList()
        : List.empty(growable: true);
  }

  Future<void> checkoutCoupon() async {
    couponState = "Pending";
    await dbManager.updateUserDetails(uid, {"couponState": "Pending"});
  }

  Future<void> updateUserVideoFromFile(
      String localFilePath, String remoteFileName) async {
    File file = File(localFilePath);
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('user_videos')
        .child(remoteFileName);

    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    currentUser.mediaUrl = downloadUrl;
    dbManager.updateUserDetails(remoteFileName, {"mediaUrl": downloadUrl});
    await updateUserVideoThumbnail(localFilePath, remoteFileName);
  }

  Future<void> updateUserVideoThumbnail(
      String localFilePath, String remoteFileName) async {
    Uint8List data = await thumbnail.VideoThumbnail.thumbnailData(
      video: localFilePath,
      imageFormat: thumbnail.ImageFormat.JPEG,
      maxWidth:
          480, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 15,
    );

    // Mirror the thumbnail image
    ImageEditorOption option = ImageEditorOption();
    option.addOption(FlipOption(horizontal: true, vertical: false));
    ImageEditor.editImage(image: data, imageEditorOption: option);

    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('userVideoThumbnail')
        .child(remoteFileName);
    final UploadTask uploadTask = ref.putData(
      data,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    currentUser.userVideoThumbnail = downloadUrl;
    await dbManager.updateUserDetails(
        remoteFileName, {"user_video_thumbnail": downloadUrl});
  }

  Future<void> updateUserSecondaryTags(List<Tag> newTags) async {
    List<Map<String, dynamic>> tags = new List();
    for (int i = 0; i < newTags.length; i++) {
      tags.add({"id": newTags[i].id, "type": newTags[i].type.index});
    }
    this.additionalTags = tags;
    await dbManager.updateUserDetails(uid, {"additionalTags": tags});
  }

  Future<void> updateUserMainTag(String tag) async {
    this.mainTag = tag;
    await dbManager.updateUserDetails(uid, {"mainTag": tag});
  }

  Future<void> updateRewardMail(String rewardMail) async {
    this.rewardMail = rewardMail;
    await dbManager.updateUserDetails(uid, {"rewardMail": rewardMail});
  }

  Future<void> updatePromoCode(String promoCode) async {
    this.promoCode = promoCode;
    await dbManager.updateUserDetails(uid, {"promoCode": promoCode});
  }

  Future<void> updateTagsCoachShown(bool shown) async {
    this.tagsCoachShown = shown;
    await dbManager.updateUserDetails(uid, {"tagsCoachShown": tagsCoachShown});
  }

  Future<void> updateUserNickname(String name) async {
    this.userName = name;
    await dbManager.updateUserDetails(uid, {"userName": name});
  }

  Future<void> updateUserGender(int gender) async {
    this.gender = gender;
    await dbManager.updateUserDetails(uid, {"gender": gender});
  }

  Future<void> updateUsergenderPreferences(int genderPreference) async {
    this.genderPreference = genderPreference;
    await dbManager
        .updateUserDetails(uid, {"genderPreference": genderPreference});
  }

  Future<void> updateFCMToken(String token) async {
    await dbManager.updateUserDetails(uid, {"fcmToken": token});
  }

  Future<void> userLiked(String otherUid) async {
    QuerySnapshot isAlreadyLiked = await dbManager.getUserLiked(uid, otherUid);
    if (isAlreadyLiked.docs.length == 0)
      await dbManager.updateUserLiked(uid, otherUid);
  }

  Future<void> userSeen(String otherUid) async {
    QuerySnapshot isAlreadySeen = await dbManager.getUserSeen(uid, otherUid);
    if (isAlreadySeen.docs.length == 0) {
      await dbManager.updateUserSeen(uid, otherUid);
      currentUser.incrementDailyViewCount();
    }
  }

  Future<void> updateBirthDate(Timestamp date) async {
    this.birthDate = date;
    await dbManager.updateUserDetails(uid, {"birthDate": birthDate});
  }

  Future<void> updateLastLogin(Timestamp time) async {
    await dbManager.updateUserDetails(uid, {"lastLogin": time});
  }

  Future<void> updateGeolocation(GeoFirePoint point) async {
    await dbManager.updateUserDetails(uid, {"position": point.data});
  }

  Future<dynamic> getPersonalizedCollection() async {
    final HttpsCallable personalizedVideos =
        FirebaseFunctions.instanceFor(region: "europe-west1")
            .httpsCallable("get_personalized_carousel");
    HttpsCallableResult res =
        await personalizedVideos.call({"tag_filter": userTagSearchFilter});
    return res.data['data'];
  }

  Stream<QuerySnapshot> getLastMessageForChat(chatRoomId) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots();
  }

  addNewChatMessage(chatId, message) {
    var data = {
      "author": currentUser.uid,
      "message": message,
      "timestamp": FieldValue.serverTimestamp()
    };
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add(data);

    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .update({"last_updated": FieldValue.serverTimestamp()});
  }

  updateSeenMessages(chatId) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .get()
        .then((value) {
      var users = value.data()['enabledUsers'];
      if (users[0] == currentUser.uid) {
        FirebaseFirestore.instance
            .collection("chats")
            .doc(chatId)
            .update({"user0_last_open": FieldValue.serverTimestamp()});
      } else {
        FirebaseFirestore.instance
            .collection("chats")
            .doc(chatId)
            .update({"user1_last_open": FieldValue.serverTimestamp()});
      }
    });
  }

  Stream<QuerySnapshot> getActiveChatRooms({startIdx, int amount = 20}) {
    return FirebaseFirestore.instance
        .collection("chats")
        .where("enabledUsers", arrayContains: currentUser.uid)
        .orderBy("last_updated", descending: true)
        .snapshots();
  }

  Future<void> keepUserAliveOnServer() async {
    await dbManager
        .updateUserDetails(uid, {"last_online": FieldValue.serverTimestamp()});

    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.data()["last_online"] != null)
      currentUser.lastServerTimestamp = snapshot.data()["last_online"];
    debugPrint("Server time: " + currentUser.lastServerTimestamp.toString());
  }

  void generateReportForOtherUser(reportReason, reportText, otherUid) async {
    final data = {
      "uid": uid,
      "reason": reportReason,
      "text": reportText,
      "timestamp": FieldValue.serverTimestamp(),
      "otherUid": otherUid,
    };

    FirebaseFirestore.instance.collection("reports").add(data);
  }

  Future<void> blockOtherUser(otherUid) async {
    final HttpsCallable f =
        FirebaseFunctions.instanceFor(region: "europe-west1")
            .httpsCallable("block_user");

    await f.call(<String, dynamic>{"otherUid": otherUid});
  }

  Future<void> updateRegistrationStage(int registrationStage) async {
    this.registrationStage = registrationStage;
    return dbManager
        .updateUserDetails(uid, {"registrationStage": registrationStage});
  }

  Stream<QuerySnapshot> getChatStream(chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> forceUserLogout() async {
    for (int i = 0; i < userPeriodicTimers.length; i++)
      userPeriodicTimers[i].cancel();
    //await FirebaseFirestore.instance.clearPersistence();
    await auth.logoutCallback();
  }

  Future<void> updateUserSettings(String setting, var value) async {
    userSettings[setting] = value;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("userSettings")
        .doc("clientSettings")
        .update({setting: value});
  }

  Future<void> updateLoginType(String providerId) async {
    if (providerId == null)
      throw Exception("Passed null social type to update social login");

    currentUser.userSettings["loginType"] = providerId;

    if (providerId == "google.com") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("userSettings")
          .doc("clientSettings")
          .update({"loginType": providerId});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("userSettings")
          .doc("socialAuth")
          .update({"google": true});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"verified": true});
      currentUser.verified = true;
    }
    if (providerId == "facebook.com") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("userSettings")
          .doc("clientSettings")
          .update({"loginType": providerId});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("userSettings")
          .doc("socialAuth")
          .update({"facebook": true});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"verified": true});
      currentUser.verified = true;
    }
    if (providerId == "password") {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("userSettings")
          .doc("clientSettings")
          .update({"loginType": providerId});
    }
  }

  Future<void> updateConnectedSocials(Map<String, bool> social) async {
    if (social.containsKey("google")) {
      currentUser.userSettings['socialAuth']['google'] = social["google"];
    }

    if (social.containsKey("facebook")) {
      currentUser.userSettings['socialAuth']['facebook'] = social["facebook"];
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("userSettings")
        .doc("socialAuth")
        .update({
      "google": currentUser.userSettings['socialAuth']['google'],
      "facebook": currentUser.userSettings['socialAuth']['facebook']
    });

    currentUser.verified = currentUser.userSettings['socialAuth']['facebook'] ||
        currentUser.userSettings['socialAuth']['google'];

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"verified": currentUser.verified});
  }

  Future<void> getTagList(String locale) async {
    int timeNow = DateTime.now().millisecondsSinceEpoch;

    if (sharedPrefs.containsKey("lastTagsUpdate")) {
      int lastTagUpdate = sharedPrefs.getInt("lastTagsUpdate");

      if (timeNow - lastTagUpdate < 24 * 60 * 60 * 1000) {
        if (sharedPrefs.containsKey("tags_" + "attributes_" + locale) &&
            sharedPrefs.containsKey("tags_" + "interests_" + locale)) {
          // Retrieve from cache
          tagAttributes = json
              .decode(sharedPrefs.getString("tags_" + "attributes_" + locale));
          tagInterests = json
              .decode(sharedPrefs.getString("tags_" + "interests_" + locale));
          return;
        }
      }
    }

    DocumentSnapshot tmp = await FirebaseFirestore.instance
        .collection("tags")
        .doc("attributes")
        .collection("locales")
        .doc(locale)
        .get();

    tagAttributes = tmp.data();

    tmp = await FirebaseFirestore.instance
        .collection("tags")
        .doc("interests")
        .collection("locales")
        .doc(locale)
        .get();

    tagInterests = tmp.data();

    // Store in cache
    sharedPrefs.setInt("lastTagsUpdate", timeNow);
    sharedPrefs.setString(
        "tags_" + "attributes_" + locale, json.encode(tagAttributes));
    sharedPrefs.setString(
        "tags_" + "interests_" + locale, json.encode(tagInterests));
  }

  Future<void> changeAccountState(String state) async {
    currentUser.accountState = state;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"accountState": state});
  }

  void updateUserTagSearchFilter(List<String> tagFilter) async {
    userTagSearchFilter = tagFilter;
  }

  Future<void> incrementDailyViewCount() async {
    numberOfVideosViewedToday++;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"numberOfVideosViewedToday": numberOfVideosViewedToday});
  }
}
