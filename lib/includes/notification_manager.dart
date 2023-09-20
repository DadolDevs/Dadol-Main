import 'package:feelingapp/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsManager {
  var logoutCallback;

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  var fcmToken;
  var notificationBarCallback;
  var videoUploadCallback;



  Future<void> init() async {
    if (!_initialized) {

      // Get permissions first
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        if (message.data['type'] == "new_match" || message.data['type'] == "new_message"){
              notificationBarCallback(true);         
          }
          if (message.data['type'] == "new_access"){
              logoutCallback();  
          }

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification}');
        }
      });
      
      /*_firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
        onMessage: (message) async {
          debugPrint(message.toString());
          debugPrint("Received message!");
          if (message['data']['type'] == "new_match" || message['data']['type'] == "new_message"){
              notificationBarCallback(true);          
          }
          if (message['data']['type'] == "new_access"){
              logoutCallback();  
          }
        },
      );*/


      // For testing purposes print the Firebase Messaging token
      fcmToken = await _firebaseMessaging.getToken();
      debugPrint("FirebaseMessaging token: $fcmToken");

      _initialized = true;
    }
  }

  void notificationHandler(RemoteMessage message) {}

  void setLogoutCallback(callback) {
    this.logoutCallback = callback;
    return;
  }

  void setNotificationBarCallback(callback) {
    this.notificationBarCallback = callback;
  }

  void setVideoUploadCallback(callback) {
    this.videoUploadCallback = callback;
  }

  void sendNotificationCallback(enabled) {
    notificationBarCallback(enabled);
  }

  Future<void> recordFCMToken() async {
    await currentUser.updateFCMToken(fcmToken);
  }
}
