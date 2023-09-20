const functions = require("firebase-functions");
const geofire = require("geofire-common");

const admin = require("firebase-admin");
const { user } = require("firebase-functions/lib/providers/auth");
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

const paidSettings = { views_per_day: 50, views_per_day_without_video: 30 };

const FIREBASE_CONFIG = process.env.FIREBASE_CONFIG && JSON.parse(process.env.FIREBASE_CONFIG);
const projectId = FIREBASE_CONFIG.projectId;
const isProduction = projectId === "feeling-c141d"

admin.firestore().settings({ timestampsInSnapshots: true });

async function validBearer(request) {
  const key = "cb05515d-7903-479d-a9bc-cb8422948ca5";

  const authorization = request.get("Authorization");
  const split =
    authorization ? authorization.split("Bearer ") : [];
  const bearerKey =
    split && split.length >= 2 ? split[1] : undefined;

  return key === bearerKey;
}

exports.getUsersActiveWithVideo = functions.https.onRequest((request, response) => {
  validBearer(request).then((valid) => {
    if (!valid) {
      response.status(400).json({
        error: "Not Authorized",
      });
      return;
    }
    const usersRef = db.collection("users").where("accountState", "==", "ActiveWithVideo");
    const mails = []
    usersRef.get().then(async function (userList) {
      const docs = userList.docs.map((doc) => {
        try {
          return { id: doc.id, mail: "", userName: doc.data().userName };
        } catch (error) {
          return response.status(500).json(error);
        }
      });

      for (const user of docs) {
        user.mail = await admin.auth()
          .getUser(user.id)
          .then((userRecord) => {
            // See the UserRecord reference doc for the contents of userRecord.
            return userRecord.email;
          })
          .catch((error) => {
            console.log('Error fetching user data:', error);
          });
      }

      return response.status(200).json(docs);
    });
  });
});

exports.calculate_loyalty = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("Europe/Rome")
  .onRun(async (context) => {
    return db
      .collection("users")
      .get()
      .then((snapshot) => {
        const loyalty_promises = [];
        //var itemsProcessed = 0;
        for (var doc of snapshot.docs) {
          console.log("processo riga: " + doc.data().uid);
          //first get days passed from last usage of the app
          var daysPassed;
          var loyaltyCumulated = 0;

          try {
            daysPassed = getNumberOfDays(doc.data().last_online.toDate(), Date.now());
          }
          catch (error) {
            daysPassed = -1;
          }

          switch (daysPassed) {
            case 0:
              loyaltyCumulated += 100;
              break;
            case 1:
              loyaltyCumulated += 100;
              break;
            case 2:
              loyaltyCumulated += 70;
              break;
            case 3:
              loyaltyCumulated += 30;
              break;
            case 4:
              loyaltyCumulated += 20;
              break;
            default:
              loyaltyCumulated += 10;
          }

          var likesN = doc.data().likedToday;

          if (likesN <= 10)
            loyaltyCumulated += 10;
          else if (likesN <= 20)
            loyaltyCumulated += 20;
          else if (likesN <= 30)
            loyaltyCumulated += 30;
          else if (likesN <= 40)
            loyaltyCumulated += 70;
          else if (likesN <= 50)
            loyaltyCumulated += 100;

          loyalty_promises.push(doc.ref.update({ loyalty: loyaltyCumulated }));
        }

        return Promise.all(loyalty_promises);

      })
      .catch((error) => {
        console.log(error);
        return null;
      });

    function getNumberOfDays(start, end) {
      const date1 = new Date(start);
      const date2 = new Date(end);

      // One day in milliseconds
      const oneDay = 1000 * 60 * 60 * 24;

      // Calculating the time difference between two dates
      const diffInTime = date2.getTime() - date1.getTime();

      // Calculating the no. of days between two dates
      const diffInDays = Math.round(diffInTime / oneDay);

      return diffInDays;
    }
  });

exports.reset_view_count = functions.pubsub
  .schedule("30 2 * * *")
  .timeZone("Europe/Rome") // Users can choose timezone - default is America/Los_Angeles
  .onRun(async (context) => {
    //reset solo se sono in produzione
    console.log("running on production: " + isProduction);
    if (isProduction === true) {
      return db
        .collection("users")
        .get()
        .then((snapshot) => {
          const reset_promises = [];
          //var itemsProcessed = 0;
          for (var doc of snapshot.docs) {
            console.log("processo riga: " + doc.data().uid);
            if (doc.data().accountState === "ActiveWithVideo") {
              try {
                mediaUrlResolve(doc.data().uid);
              }
              catch (error) {
                console.error("Error occurred during the execution of mediaUrlResolve. This should not happen.")
              }
            }

            reset_promises.push(doc.ref.update({ numberOfVideosViewedToday: 0 }));
            reset_promises.push(doc.ref.update({ likedToday: 0 }));

          }

          return Promise.all(reset_promises);

        })
        .catch((error) => {
          console.log(error);
          return null;
        });
    }
  });

exports.onUSerCreate = functions
  .region("europe-west1")
  .firestore.document("users/{userId}")
  .onCreate((snap, context) => {
    updSubscriptionReward(snap);
    return snap.ref.update({ likedByN: 0 });
  });

exports.onUserCouponSent = functions
  .region("europe-west1")
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const previousValue = change.before.data();
    const newValue = change.after.data();
    const prevState = previousValue.couponState;
    const newState = newValue.couponState;

    const rewardSnap = await db.collection("settings").doc("reward").get();
    const rewardSettings = rewardSnap.data();
    if (rewardSettings.campaignOn === true) {
      if (prevState === "Pending" && newState === "Sent") {
        //changed to active with video, send notification
        if (newValue.preferredLocale === 'it') {
          const payload = {
            notification: {
              title: "il tuo buono è stato inviato",
              body: "a breve riceverai una mail contenente il buono amazon richiesto!",
            },
            data: { type: "coupon" },
          };
          send_notification(newValue.uid, "other", payload);
        } else {
          const payload = {
            notification: {
              title: "your coupon has been sent",
              body: "you're going to receive an email with the requested amazon coupon!",
            },
            data: { type: "coupon" },
          };
          send_notification(newValue.uid, "other", payload);
        }
      }
    }
  });




exports.onUserLoginWithouReward = functions
  .region("europe-west1")
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const previousValue = change.before.data();
    const newValue = change.after.data();
    const prevState = previousValue.numberOfVideosViewedToday;
    const newState = newValue.numberOfVideosViewedToday;

    const rewardSnap = await db.collection("settings").doc("reward").get();
    const rewardSettings = rewardSnap.data();
    if (rewardSettings.campaignOn === true) {
      if (prevState === 4 && newState === 5) {
        if (newValue.registrationStage == 2) {
          if (newValue.rewardInfoSent !== true) {
            change.after.ref.update({ "rewardInfoSent": true });
            //changed to active with video, send notification
            if (newValue.preferredLocale === 'it') {
              const payload = {
                notification: {
                  title: "ritira il tuo premio",
                  body: "invita amici e amiche per ottenere buoni amazon!",
                },
                data: { type: "reward_info" },
              };
              send_notification(newValue.uid, "other", payload);
            } else {
              const payload = {
                notification: {
                  title: "get your reward",
                  body: "invite your friends to get amazon coupons!",
                },
                data: { type: "reward_info" },
              };
              send_notification(newValue.uid, "other", payload);
            }
          }
        }
      }
    }
  });

exports.onVideoAccepted = functions
  .region("europe-west1")
  .firestore
  .document('users/{userId}')
  .onUpdate((change, context) => {
    const previousValue = change.before.data();
    const newValue = change.after.data();
    const prevState = previousValue.accountState;
    const newState = newValue.accountState;

    if (prevState === "Pending" && newState === "ActiveWithVideo") {
      //changed to active with video, send notification
      if (newValue.preferredLocale === 'it') {
        const payload = {
          notification: {
            title: "Complimenti!",
            body: "Il tuo video è stato approvato. Hai sbloccato tutte le funzionalità di Dadol! Buon divertimento!",
          },
          data: { type: "video_accepted" },
        };
        send_notification(newValue.uid, "other", payload);
      } else {
        const payload = {
          notification: {
            title: "Congratulations!",
            body: "Your video has been approved. You have unlocked all the features of Dadol! Have fun!",
          },
          data: { type: "video_accepted" },
        };
        send_notification(newValue.uid, "other", payload);
      }

      if (newValue.firstVideoAccepted !== true) {
        change.after.ref.update({ "firstVideoAccepted": true });
        updApprovedVideoReward(change.after);
      }
    }
  });

exports.onVideoRefused = functions
  .region("europe-west1")
  .firestore
  .document('users/{userId}')
  .onUpdate((change, context) => {
    const previousValue = change.before.data();
    const newValue = change.after.data();
    const prevState = previousValue.accountState;
    const newState = newValue.accountState;

    if (prevState === "Pending" && newState === "ActiveRefusedVideo") {
      if (newValue.preferredLocale === 'it') {
        //changed to active with video, send notification
        const payload = {
          notification: {
            title: "Ci dispiace molto.",
            body: "Il tuo video è stato rifiutato perché non rispetta gli standard della community. Clicca qui per maggiori info.",
          },
          data: { type: "video_refused" },
        };
        send_notification(newValue.uid, "other", payload);
      } else {
        const payload = {
          notification: {
            title: "We are very sorry.",
            body: "Your video was rejected because it doesn't meet community standards. Click here for more info.",
          },
          data: { type: "video_refused" },
        };
        send_notification(newValue.uid, "other", payload);
      }
    }
  });

// Intercepts likes, adds liked_by to the other_uid, if there is a match create a chat.
exports.like_create_chat = functions
  .region("europe-west1")
  .firestore.document("users/{user_id}/likes/{like_id}")
  .onCreate((snap, context) => {
    const this_uid = context.params.user_id;
    const new_like = snap.data();
    const other_uid = new_like.uid;
    snap.ref.update({ user_ref: db.doc(`/users/${other_uid}`) });
    functions.logger.log("this_uid: ", this_uid, " other_uid: ", other_uid);

    return like_create_chat(this_uid, other_uid);
  });

exports.message_sent = functions
  .region("europe-west1")
  .firestore.document("chats/{chat_id}/messages/{message_id}")
  .onCreate((snap, context) => {
    const chat_id = context.params.chat_id;
    const message_id = context.params.message_id;
    return send_new_message_notification(chat_id, message_id);
  });

exports.user_logged_in = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return user_logged_in(context.auth.uid, data.fcmToken);
  });

exports.get_personalized_carousel = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return get_personalized_carousel(context.auth.uid, data.tag_filter);
  });

exports.get_personalized_videos = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return get_personalized_videos(context.auth.uid, data.tag_filter);
  });

exports.get_data_by_uid = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return get_data_by_uid(data.uid);
  });

exports.block_user = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return block_user(context.auth.uid, data.otherUid);
  });

exports.delete_account = functions
  .region("europe-west1")
  .https.onCall((data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Unauthorized"
      );
    return delete_account(context.auth.uid, data.motivation);
  });

async function getCurrentSpecialReward() {
  const specialsRef = db.collection("settings").doc("reward").collection("specials");
  const query = specialsRef.where("toDate", ">=", new Date());
  var specials = await query.get();
  specials = specials.docs.filter((i) => {
    console.log(i.data().fromDate);
    return i.data().fromDate.toDate() <= new Date();
  });
  console.log(specials.length);
  if (specials.length > 0) {
    return specials[0].data();
  }
}

async function updSubscriptionReward(snap) {
  const user = snap.data();
  if (user.inviteCode !== null && user.inviteCode !== '') {
    const rewardSnap = await db.collection("settings").doc("reward").get();
    var rewardSettings = rewardSnap.data();
    const specialRewardSetting = await getCurrentSpecialReward();
    if (specialRewardSetting != undefined) {
      rewardSettings = specialRewardSetting;
    }
    var querySnapshot = await db.collection("users").where("promoCode", "==", user.inviteCode).get();
    if (querySnapshot.docs.length === 1) {
      snap.ref.update({ "reward.cumulated": rewardSettings.subscriptionReward });
    }

  }
}

async function updApprovedVideoReward(snap) {
  const user = snap.data();
  if (user.inviteCode !== null && user.inviteCode !== '') {
    // do something
    try {
      var querySnapshot = await db.collection("users").where("promoCode", "==", user.inviteCode).get();
      if (querySnapshot.docs.length === 1) {
        const invitingUser = querySnapshot.docs[0];
        var previousCumulated = invitingUser.data().reward.cumulated;

        const specialRewardSetting = await getCurrentSpecialReward();
        if (specialRewardSetting != undefined) {
          previousCumulated = previousCumulated + specialRewardSetting.inviteReward;
        } else {
          previousCumulated = previousCumulated + invitingUser.data().reward.inviteReward;
        }

        var subscribed = invitingUser.data().reward.subscribed;
        subscribed = subscribed + 1;
        await invitingUser.ref.update({ "reward.cumulated": previousCumulated, "reward.subscribed": subscribed });
      }
    } catch (e) {
      console.log(e);
    }
  }
}

// Deletes the chat and ads both users to the blocked list
async function block_user(this_uid, other_uid) {
  await db
    .collection("users")
    .doc(this_uid)
    .collection("blocked")
    .add({
      uid: other_uid,
      date: admin.firestore.Timestamp.fromDate(new Date()),
    });
  await db
    .collection("users")
    .doc(other_uid)
    .collection("blocked")
    .add({
      uid: this_uid,
      date: admin.firestore.Timestamp.fromDate(new Date()),
    });
  var activeChats = await db
    .collection("chats")
    .where("enabledUsers", "array-contains", this_uid)
    .get();

  var indexToDelete = 0;
  for (var i = 0; i < activeChats.size; i++) {
    if (activeChats.docs[i].data().enabledUsers.includes(other_uid)) {
      indexToDelete = i;
      break;
    }
  }
  await db.collection("chats").doc(activeChats.docs[indexToDelete].id).delete();
  return;

  // Delete chat

  // Add to blocked for this_uid
}

async function like_create_chat(this_uid, other_uid) {
  // Make sure there are no double likes by first querying the database
  const double_like_check = await db
    .collection("users")
    .doc(other_uid)
    .collection("liked_by")
    .where("uid", "==", this_uid)
    .get();
  functions.logger.log("Double like check: ", double_like_check);
  if (double_like_check.empty) {
    console.log("Liked_by is empty");
    await db
      .collection("users")
      .doc(other_uid)
      .collection("liked_by")
      .add({
        uid: this_uid,
        date: admin.firestore.Timestamp.fromDate(new Date()),
        user_ref: db.doc(`/users/${this_uid}`),
      });
    console.log("Inserted liked_by");

    // Update engagement statistics
    await db
      .collection("users")
      .doc(other_uid)
      .update({ likedByN: admin.firestore.FieldValue.increment(1) });
    await db
      .collection("users")
      .doc(this_uid)
      .update({ likesN: admin.firestore.FieldValue.increment(1) });
    await db
      .collection("users")
      .doc(this_uid)
      .update({ likedToday: admin.firestore.FieldValue.increment(1) });
  }
  // Check if the match is mutual, if so create a chat and send a push notification to both users
  const mutual_like = await db
    .collection("users")
    .doc(this_uid)
    .collection("liked_by")
    .where("uid", "==", other_uid)
    .get();

  if (!mutual_like.empty) {
    console.log("Creating chat!");
    create_chat(this_uid, other_uid);
    send_new_match_notification(this_uid, other_uid);
  }
  else {
    console.log("Non creating chat!");
  }

  return 0;
}

async function get_personalized_carousel(uid, tag_filters) {

  var likers = [];

  // Load your profile
  var currentUser = await db.collection("users").doc(uid).get();

  var excludedUsers = [];

  // Exclude yourself
  excludedUsers.push(uid);

  // Get age range
  const deltaAge = 12;
  var userYearsInMilliseconds =
    Date.now() - currentUser.data().birthDate.toMillis();
  var lowerAge =
    (Date.now() -
      userYearsInMilliseconds -
      deltaAge * 365 * 24 * 60 * 60 * 1000) /
    1000;
  var upperAge =
    (Date.now() -
      userYearsInMilliseconds +
      deltaAge * 365 * 24 * 60 * 60 * 1000) /
    1000;

  // Do not show the last N saw users
  var seenUsers = db
    .collection("users")
    .doc(uid)
    .collection("saw")
    .orderBy("date", "desc")
    .limit(500) // N
    .get();

  // Do not show liked users
  var likedUsers = db
    .collection("users")
    .doc(uid)
    .collection("likes")
    .get();

  // Get all UIDs who liked me
  var likedBylist = await db
    .collection("users")
    .doc(uid)
    .collection("liked_by")
    .get();

  // Compute all users to exclude
  await Promise.all([seenUsers, likedUsers])
    .then((snapshots) => {
      snapshots.forEach((snapshot) => {
        snapshot.forEach((doc) => {
          excludedUsers.push(doc.data().uid);
        });
      });
      return;
    })
    .catch((error) => {
      console.log(error);
      return null;
    });

  // Get documents of users who liked me
  var likedUsersPromises = [];
  for (d of likedBylist.docs) {
    excludedUsers.push(d.data().uid);
    if (!d.data().user_ref) continue;
    const q = d.data().user_ref;
    likedUsersPromises.push(q.get());
  }

  //define gender preferences array
  var genderPreferences;
  if (currentUser.data().genderPreference === 2)
    genderPreferences = [0, 1];
  else
    genderPreferences = [currentUser.data().genderPreference];

  var likedByUsers = await Promise.all(likedUsersPromises);

  //filter likedBy to get LIKERS GROUP
  for (user_d of likedByUsers) {
    if (
      genderPreferences.includes(user_d.data().genderPreference) &&
      user_d.data().accountState === "ActiveWithVideo" &&
      genderPreferences.includes(d.data().gender) &&
      user_d.data().mediaUrl !== "" &&
      user_d.data().birthDate.seconds < upperAge &&
      user_d.data().birthDate.seconds > lowerAge
    ) {
      //add to likers group
      likers.push(user_d);
    }
  }

  //get ALL eligible users
  var qEligibleUsers;
  if (genderPreferences.length === 1) {
    qEligibleUsers = await db
      .collection("users")
      .where("genderPreference", "in", [2, currentUser.data().gender])
      .where("accountState", "==", "ActiveWithVideo")
      .where("gender", "==", genderPreferences[0])
      .where("mediaUrl", "!=", "")
      .get();
  } else {
    //without gender specification
    qEligibleUsers = await db
      .collection("users")
      .where("genderPreference", "in", [2, currentUser.data().gender])
      .where("accountState", "==", "ActiveWithVideo")
      .where("mediaUrl", "!=", "")
      .get();
  }

  //get ALL fake users
  var qFakeUsers;
  if (genderPreferences.length === 1) {
    qFakeUsers = await db
      .collection("users")
      .where("genderPreference", "in", [2, currentUser.data().gender])
      .where("accountState", "==", "Sponsored")
      .where("mediaUrl", "!=", "")
      .where("gender", "==", genderPreferences[0])
      .get();
  } else {
    //without gender specification
    qFakeUsers = await db
      .collection("users")
      .where("genderPreference", "in", [2, currentUser.data().gender])
      .where("accountState", "==", "Sponsored")
      .where("mediaUrl", "!=", "")
      .get();
  }

  var eligibleUsers = [];
  var center = [
    Number(currentUser.data().position.geopoint.latitude),
    Number(currentUser.data().position.geopoint.longitude),
  ];

  for (const doc of qEligibleUsers.docs) {
    if (doc.data().position != null) {
      console.log(doc.data().position);
      const lat = doc.data().position.geopoint.latitude;
      const lng = doc.data().position.geopoint.longitude;

      const distanceInKm = geofire.distanceBetween([lat, lng], center);
      const distanceInM = distanceInKm * 1000;

      if (distanceInM <= 250000) {
        eligibleUsers.push(doc);
      }
    }
  }

  const fakeUsers = qFakeUsers.docs;

  var usersArray = eligibleUsers.concat(fakeUsers);

  //remove excluded from the beginning (seen, likers, liked)
  usersArray = usersArray.filter(i => !excludedUsers.includes(i.data().uid));

  var tagsEligibleUsers = usersArray.filter(d => {
    if (d.data().additionalTags.length > 0) {
      var tagIds = d.data().additionalTags.map((tag) => tag.id);
      return tagIds.some((item) => tag_filters.includes(item));
    }
  }).map((vid) => vid.data());

  function byLikes(a, b) {
    if (a.data().likedByN > b.data().likedByN) return 1;
    if (b.data().likedByN > a.data().likedByN) return -1;
    return 0;
  }

  function byLoyalty(a, b) {
    if (a.data().loyalty > b.data().loyalty) return 1;
    if (b.data().loyalty > a.data().loyalty) return -1;
    return 0;
  }

  bests = usersArray.sort(byLikes).slice(0, 25);

  for (d of bests) {
    excludedUsers.push(d.data().uid);
  }

  //filter the bests
  usersArray = usersArray.filter(i => !excludedUsers.includes(i.data().uid));
  loyals = usersArray.sort(byLoyalty).slice(0, 25);

  var numberOfVideosViewedToday = currentUser.data().numberOfVideosViewedToday;
  if (!numberOfVideosViewedToday) numberOfVideosViewedToday = 0;

  var remainingVideosToWatch = Math.max(
    0,
    paidSettings.views_per_day - numberOfVideosViewedToday
  );

  if (remainingVideosToWatch <= 1) {
    // 1 because I consider a user as seen only once the page is scrolled
    res = { data: [{ uid: "view_limit_reached" }] }
    return res
  }

  var allusers = [];

  if (tag_filters.length > 0) {

    allusers = tagsEligibleUsers;
    if (allusers.length < remainingVideosToWatch)
      allusers = allusers.concat(getFormedCarousel(remainingVideosToWatch - allusers.length, likers, bests, loyals));
  } else {
    //get videos with algorythm
    allusers = allusers.concat(getFormedCarousel(remainingVideosToWatch, likers, bests, loyals));
  }

  if (allusers.length < remainingVideosToWatch) {
    allusers.push({ uid: "no_more_videos" });
  } else if (remainingVideosToWatch < paidSettings.views_per_day) {
    allusers.push({ uid: "view_limit_reached" });
  }

  function byFakes(a, b) {
    if (a.uid == "no_more_videos") return -1;
    if (a.accountState == "Sponsored" && b.accountState != "Sponsored") return 1;
    if (b.accountState == "Sponsored" && a.accountState != "Sponsored") return -1;
    return 0;
  }

  if (currentUser.data().seenFirstCarousel != true) {
    console.log("first carousel!");
    currentUser.ref.update({ "seenFirstCarousel": true });
    allusers.sort(byFakes);
  }

  return { data: allusers };
}

function getNextCarouselVideo(groups, probs) {
  const randInt = Math.floor(Math.random() * 100) + 1;
  var cumulativeProb = 0;
  var atLeastOne = false;
  //check if at least one record exist

  for (let i = 0; i < groups.length; i++) {
    if (groups[i].length > 0) {
      atLeastOne = true;
    }
  }

  //no more records
  if (atLeastOne === false) {
    return { uid: "no_more_videos" };
  }

  for (let i = 0; i < probs.length; i++) {
    cumulativeProb += probs[i];
    if (randInt <= cumulativeProb) {

      const idxOf = i;
      if (groups[idxOf].length >= 1) {
        const video = groups[idxOf].shift();
        return video.data();
      }
      else {
        //need to call getNextCarouselVideo excluding the group
        var newGroups = groups.slice();
        var remainingProbs = probs.slice();

        //remove the empty element
        newGroups.splice(idxOf, 1);
        remainingProbs.splice(idxOf, 1);

        var newTot = 0;
        for (let iTot = 0; iTot < remainingProbs.length; iTot++) {
          newTot += remainingProbs[iTot];
        }

        var newProbs = [];
        for (let iProbs = 0; iProbs < remainingProbs.length; iProbs++) {
          newProbs.push(Math.round(remainingProbs[iProbs] / newTot * 100));
        }

        return getNextCarouselVideo(newGroups, newProbs);
      }
    }
  }
}

function getFormedCarousel(howMany, likers, bests, loyals) {
  const groups = [likers, bests, loyals];
  var carousel = [];
  for (let iC = 0; iC <= howMany; iC++) {
    const tierPerc = (100 / howMany) * iC;
    if (tierPerc <= 10) {
      //TOP TIER
      const video = getNextCarouselVideo(groups, [70, 15, 15]);
      carousel.push(video);
      continue;
    } else if (tierPerc <= 30) {
      //MID TOP TIER
      const video = getNextCarouselVideo(groups, [60, 20, 20]);
      carousel.push(video);
      continue;
    } else if (tierPerc <= 60) {
      //MID TIER
      const video = getNextCarouselVideo(groups, [50, 25, 25]);
      carousel.push(video);
      continue;
    } else if (tierPerc <= 100) {
      //LOW TIER
      const video = getNextCarouselVideo(groups, [30, 35, 35]);
      carousel.push(video);
      continue;
    }
  }
  return carousel;
}

async function getPersonalizedQuery(
  center,
  radiusInM,
  gender_pref,
  otherGender,
  upperAge,
  lowerAge,
  tagFilter,
  excludedUsers,
  usersWhoLikeMe
) {
  var matchedOtherUsers = [];
  var matchedTagUsers = [];
  const bounds = geofire.geohashQueryBounds(center, radiusInM);
  const promises = [];
  var fakeUsers;

  // Get documents of users who liked me in parallel
  var likedUsersPromises = [];
  for (d of usersWhoLikeMe) {
    if (!d.data().user_ref) continue;
    const q = d.data().user_ref;
    likedUsersPromises.push(q.get());
  }
  var userDocsWhoLikedMe = await Promise.all(likedUsersPromises);

  // Filter users who liked me
  var usersWhoLikeMeFiltered = [];
  for (d of userDocsWhoLikedMe) {
    if (!Array.isArray(otherGender)) {
      // Must filter per gender
      console.log("Using first condition");
      if (
        gender_pref.includes(d.data().genderPreference) &&
        d.data().accountState === "ActiveWithVideo" &&
        d.data().gender === otherGender &&
        d.data().mediaUrl !== "" &&
        d.data().birthDate.seconds < upperAge &&
        d.data().birthDate.seconds > lowerAge
      ) {
        usersWhoLikeMeFiltered.push(d);
      }
    } else {
      // Don't care about gender
      console.log("Using second condition");
      if (
        gender_pref.includes(d.data().genderPreference) &&
        d.data().accountState === "ActiveWithVideo" &&
        d.data().mediaUrl !== "" &&
        d.data().birthDate.seconds < upperAge &&
        d.data().birthDate.seconds > lowerAge
      ) {
        usersWhoLikeMeFiltered.push(d);
      }
    }
  }
  /*console.log("User who liked me " + usersWhoLikeMe)
  console.log("User who liked me docs " + userDocsWhoLikedMe)
  console.log("User who liked me filtered " + usersWhoLikeMeFiltered)

  for(d of usersWhoLikeMeFiltered){
    console.log(d.data().userName)
  }*/

  if (!Array.isArray(otherGender)) {
    for (const b of bounds) {
      const q = db
        .collection("users")
        .where("genderPreference", "in", gender_pref)
        .where("accountState", "==", "ActiveWithVideo")
        .where("gender", "==", otherGender)
        .orderBy("position.geohash")
        .orderBy("likedByN", "desc")
        .startAt(b[0])
        .endAt(b[1]);
      promises.push(q.get());
    }
    fakeUsers = await db
      .collection("users")
      .where("genderPreference", "in", gender_pref)
      .where("accountState", "==", "Sponsored")
      .where("gender", "==", otherGender)
      .orderBy("likedByN", "desc")
      .get();
  } else {
    // Only for bisexuals (equivalent to taking any gender who is attracted to me or who is bisexual as me)
    for (const b of bounds) {
      const q = db
        .collection("users")
        .where("genderPreference", "in", gender_pref)
        .where("accountState", "==", "ActiveWithVideo")
        .orderBy("position.geohash")
        .orderBy("likedByN", "desc")
        .startAt(b[0])
        .endAt(b[1]);
      promises.push(q.get());
    }
    fakeUsers = await db
      .collection("users")
      .where("genderPreference", "in", gender_pref)
      .where("accountState", "==", "Sponsored")
      .orderBy("likedByN", "desc")
      .get();
  }

  await Promise.all(promises)
    .then((snapshots) => {
      const matchingDocs = [];
      for (const snap of snapshots) {
        console.log("Got " + snap.size + " real users");
        for (const doc of snap.docs) {
          const lat = doc.get("position.geopoint").latitude;
          const lng = doc.get("position.geopoint").longitude;

          const distanceInKm = geofire.distanceBetween([lat, lng], center);
          const distanceInM = distanceInKm * 1000;
          // REMOVE COMMENT TO FILTER BY DISTANCE
          if (distanceInM >= 1) {
            matchingDocs.push(doc);
          }
        }
      }

      var fakeUsersDocs = [];
      for (const doc of fakeUsers.docs) {
        fakeUsersDocs.push(doc);
      }

      /*fakeUsersDocs.sort(function (a, b) {
        return b.data().likedByN - a.data().likedByN;
      });*/

      // Add fake users
      for (const doc of fakeUsersDocs) {
        if (!matchingDocs.includes(doc)) {
          matchingDocs.push(doc);
        }
      }

      return matchingDocs;
    })
    .then((matchingDocs) => {
      // Normal + fake users
      for (d of matchingDocs) {
        // Avoid ill-formed entries
        if (!d.data().birthDate) continue;
        // Filter by age
        if (
          d.data().birthDate.seconds < upperAge &&
          d.data().birthDate.seconds > lowerAge
        ) {
          // Filter missing video
          if (d.data().mediaUrl === "") {
            continue;
          }
          // Filter by exclusion
          if (excludedUsers.includes(d.data().uid)) {
            continue;
          }

          // Filter by tag
          if (tagFilter.length > 0 && d.data().additionalTags.length > 0) {
            var tagIds = d.data().additionalTags.map((tag) => tag.id);
            if (tagIds.some((item) => tagFilter.includes(item))) {
              matchedTagUsers.push({
                mediaUrl: d.data().mediaUrl,
                uid: d.data().uid,
                userName: d.data().userName,
                user_video_thumbnail: d.data().user_video_thumbnail,
                verified: d.data().verified,
                additionalTags: d.data().additionalTags,
              });
              continue; // Avoid double add of users
            }
          }

          matchedOtherUsers.push({
            mediaUrl: d.data().mediaUrl,
            uid: d.data().uid,
            userName: d.data().userName,
            user_video_thumbnail: d.data().user_video_thumbnail,
            verified: d.data().verified,
            additionalTags: d.data().additionalTags,
          });

        }
        if (matchedOtherUsers.length + matchedTagUsers.length > 100) {
          break;
        }
      }
      // Add users who liked me at the beginning
      for (const d of usersWhoLikeMeFiltered)
        matchedOtherUsers.unshift({
          mediaUrl: d.data().mediaUrl,
          uid: d.data().uid,
          userName: d.data().userName,
          user_video_thumbnail: d.data().user_video_thumbnail,
          verified: d.data().verified,
          additionalTags: d.data().additionalTags,
        });
      shuffleArray(matchedOtherUsers, usersWhoLikeMeFiltered.length);

      return 0;
    });
  return matchedTagUsers.concat(matchedOtherUsers);
}

function mediaUrlResolve(uid) {
  console.log("test: " + uid + ", project: " + projectId + ".appspot.com");
  const bucket = storage.bucket(projectId + ".appspot.com");
  const storageFile = bucket.file("user_videos/" + uid);
  storageFile
    .exists()
    .then((exists) => {
      if (exists[0]) {
        console.log("video presente");
      } else {
        console.log("video assente: " + uid);
        db.collection("users").doc(uid).update({ accountState: "VideoError" });
      }
      return 0;
    }).catch((error) => {
      console.log(error);
      return -1;
    });
}

function shuffleArray(array, prefixElementsLength) {
  if (prefixElementsLength === 0) return;

  var shuffleExtent = array.length;
  if (array.length > 2 * prefixElementsLength) {
    shuffleExtent = 2 * prefixElementsLength;
  }
  for (var i = shuffleExtent - 1; i > 0; i--) {
    var j = Math.floor(Math.random() * (i + 1));
    var temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
}

async function get_data_by_uid(other_uid) {
  var d = await db.collection("users").doc(other_uid).get();

  return {
    data: {
      mediaUrl: d.data().mediaUrl,
      uid: d.data().uid,
      userName: d.data().userName,
      user_video_thumbnail: d.data().user_video_thumbnail,
      verified: d.data().verified,
      additionalTags: d.data().additionalTags,
      last_online: d.data().last_online,
    },
  };
}


async function get_personalized_videos(uid, tag_filters) {
  var excludeUsers = [];
  // Exclude yourself
  excludeUsers.push(uid);
  // Load your profile
  var currentUser = await db.collection("users").doc(uid).get();

  // Do not show the last N saw users
  var lastSeenUsers = db
    .collection("users")
    .doc(uid)
    .collection("saw")
    .orderBy("date", "desc")
    .limit(500) // N
    .get();

  // Do not show liked users
  var lastLikedUsers = db
    .collection("users")
    .doc(uid)
    .collection("likes")
    .get();

  // Get all users who like me
  var usersWhoLikeMeUnfiltered = await db
    .collection("users")
    .doc(uid)
    .collection("liked_by")
    .get();

  // Return a request to load a video if the quota is exceeded
  if (currentUser.data().numberOfVideosViewed >= paidSettings.views_per_day_without_video && currentUser.data().mediaUrl === "") {
    return { data: [{ uid: "video_upload_required" }] }
  }

  // Compute all users to exclude
  await Promise.all([lastSeenUsers, lastLikedUsers])
    .then((snapshots) => {
      snapshots.forEach((snapshot) => {
        snapshot.forEach((doc) => {
          excludeUsers.push(doc.data().uid);
        });
      });
      return;
    })
    .catch((error) => {
      console.log(error);
      return null;
    });

  // Prepare the exclusion string for the users who liked me for subsequent merge at the end of the function
  var usersWhoLikeMe = [];
  for (d of usersWhoLikeMeUnfiltered.docs) {
    if (!excludeUsers.includes(d.data().uid)) {
      usersWhoLikeMe.push(d);
      excludeUsers.push(d.data().uid);
    }
  }

  // Setup user gender preference
  var otherGender;
  var otherGenderPreference;

  // Homosexual
  if (currentUser.data().gender === currentUser.data().genderPreference) {
    otherGender = currentUser.data().gender;
    otherGenderPreference = [currentUser.data().gender, 2];
  }
  // Heterosexual
  else if (
    currentUser.data().gender !== currentUser.data().genderPreference &&
    currentUser.data().genderPreference < 2
  ) {
    otherGender = currentUser.data().genderPreference;
    otherGenderPreference = [currentUser.data().gender, 2];
  }
  // Bisexual
  else if (currentUser.data().gender !== currentUser.data().genderPreference) {
    otherGender = [0, 1];
    //otherGenderPreference = currentUser.data().gender;
    otherGenderPreference = [currentUser.data().gender, 2]; // My gender or bisexual
  }

  // Get age range
  const deltaAge = 12;
  var userYearsInMilliseconds =
    Date.now() - currentUser.data().birthDate.toMillis();
  var lowerAge =
    (Date.now() -
      userYearsInMilliseconds -
      deltaAge * 365 * 24 * 60 * 60 * 1000) /
    1000;
  var upperAge =
    (Date.now() -
      userYearsInMilliseconds +
      deltaAge * 365 * 24 * 60 * 60 * 1000) /
    1000;

  // Get a personalized user list
  var allUsers = await getPersonalizedQuery(
    [
      Number(currentUser.data().position.geopoint.latitude),
      Number(currentUser.data().position.geopoint.longitude),
    ],
    75000,
    otherGenderPreference,
    otherGender,
    upperAge,
    lowerAge,
    tag_filters,
    excludeUsers,
    usersWhoLikeMe
  );

  var maxViewsPerDay = paidSettings.views_per_day;

  var numberOfVideosViewedToday = currentUser.data().numberOfVideosViewedToday;
  if (!numberOfVideosViewedToday) numberOfVideosViewedToday = 0;

  var remainingVideosToWatch = Math.max(
    0,
    maxViewsPerDay - numberOfVideosViewedToday
  );

  if (allUsers.length < remainingVideosToWatch) {
    allUsers.push({ uid: "no_more_videos" });
    return { data: allUsers };
  }

  if (remainingVideosToWatch <= 1) {
    // 1 because I consider a user as seen only once the page is scrolled
    res = { data: [{ uid: "view_limit_reached" }] }
    if (currentUser.data().mediaUrl === "")
      res = { data: [{ uid: "video_upload_required" }] }
    return res
  }

  allUsers = allUsers.slice(
    0,
    Math.min(allUsers.length, remainingVideosToWatch)
  );
  if (currentUser.data().mediaUrl === "")
    allUsers.push({ uid: "video_upload_required" });
  else
    allUsers.push({ uid: "view_limit_reached" });

  return { data: allUsers };
}

async function send_notification(uid, type, payload) {
  var receiverSettings = await db
    .collection("users")
    .doc(uid)
    .collection("userSettings")
    .doc("clientSettings")
    .get();

  var receiver = await db.collection("users").doc(uid).get();

  if (
    receiver.data().accountState === "Deleted" ||
    receiver.data().accountState === "Suspended"
  )
    return;

  if (
    type === "match" &&
    receiverSettings.data().matchPushNotifications === false
  )
    return;

  if (
    type === "message" &&
    receiverSettings.data().messagePushNotifications === false
  )
    return;

  if (
    type === "other" &&
    receiverSettings.data().otherPushNotifications === false
  )
    return;

  admin.messaging().sendToDevice(receiver.data().fcmToken, payload);
}

async function send_new_match_notification(this_uid, other_uid) {
  const payload = {
    notification: {
      title: "Hai una nuova compatibilità",
      body: "Entra per scoprirla",
    },
    data: { type: "new_match" },
  };

  send_notification(this_uid, "match", payload);
  send_notification(other_uid, "match", payload);
}

async function send_new_message_notification(chat_id, message_id) {
  var message = await db
    .collection("chats")
    .doc(chat_id)
    .collection("messages")
    .doc(message_id)
    .get();
  var sender = await db.collection("users").doc(message.data().author).get();

  var chat = await db.collection("chats").doc(chat_id).get();

  var receiverId = chat.data().enabledUsers[0];
  if (chat.data().enabledUsers[0] === message.data().author)
    receiverId = chat.data().enabledUsers[1];

  const payload = {
    notification: {
      title: sender.data().userName,
      body: message.data().message,
      tag: sender.data().uid,
    },
    data: { type: "new_message" },
  };
  send_notification(receiverId, "message", payload);
}

async function create_chat(this_uid, other_uid) {
  const newChatData = {
    enabledUsers: [this_uid, other_uid],
    last_updated: admin.firestore.Timestamp.fromDate(new Date()),
    user0_last_open: admin.firestore.Timestamp.fromMillis(0),
    user1_last_open: admin.firestore.Timestamp.fromMillis(0),
    created: admin.firestore.Timestamp.fromDate(new Date()),
  };
  const chat = await db.collection("chats").add(newChatData);
}

async function user_logged_in(uid, fcmToken) {
  //console.log(context);
  var receiver = await db.collection("users").doc(uid).get();

  if (receiver.data().fcmToken === fcmToken) return 0;

  await admin.auth().revokeRefreshTokens(uid);

  const payload = {
    notification: {
      title: "Hai effettuato un accesso da un'altro dispositivo",
      body: "Non ti risulta? Resetta la password il prima possibile.",
    },
    data: { type: "new_access" },
  };

  admin.messaging().sendToDevice(receiver.data().fcmToken, payload);
  return 0;
}

async function delete_account(uid, motivation) {
  await db.collection("users").doc(uid).update({ accountState: "Deleted" });

  await db.collection("users").doc(uid).collection("logs").add({
    type: "AccountDeleted",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    data: motivation,
  });
  //await db.collection("users").doc(uid).delete(); //TODO: uncomment this to clear the DB from the user
  admin.auth().deleteUser(uid);
}