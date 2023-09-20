import 'dart:async';
import 'dart:io';
import 'package:feelingapp/views/messages/chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'includes/auth.dart';
import 'includes/database_manager.dart';
import 'includes/notification_manager.dart';
import 'includes/server_settings.dart';
import 'includes/user.dart';
import 'routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

var streamController = new StreamController.broadcast();
RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
AppUser currentUser = new AppUser();
PushNotificationsManager pushNotificationService =
    new PushNotificationsManager();
ServerSettings serverSettings = new ServerSettings();
DatabaseManager dbManager = DatabaseManager();
List<Timer> userPeriodicTimers = [];
Localizations locale;
BaseAuth auth = BaseAuth();
SharedPreferences sharedPrefs;
bool isVideoUploadRunning = false;
bool viewingCarousel = true;
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");
AppleSignInAvailable appleSignInAvailable;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  navigatorKey.currentState.push(MaterialPageRoute(
      builder: (_) => ChatPage(
          otherUid: "9G7pg9FSkiMVGjlBU1F8flmreQ32",
          otherName: "gergoogle",
          otherPic:
              "https://firebasestorage.googleapis.com/v0/b/feeling-c141d.appspot.com/o/userVideoThumbnail%2F9G7pg9FSkiMVGjlBU1F8flmreQ32?alt=media&token=68459a8f-31ca-4354-a540-72b55ecd58f8",
          created: 0)));
}

void main() async {
  // Start the push notification manager
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  if (Platform.isIOS) appleSignInAvailable = await AppleSignInAvailable.check();

  // Push notifications configuration
  pushNotificationService.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Return the app
  new Routes();
}
