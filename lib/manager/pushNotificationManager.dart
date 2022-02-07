import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AgoraDemo/main.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  SharedPreferences prefs;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();

      _firebaseMessaging.configure(
        // When app is in foreground
        onMessage: (message) async {
          developer.log(message.toString(), name: "onMessage");
          _checkForSignInForVideoCall();
        },
        // When user terminate the app and accepts notification
        onLaunch: (message) async {
          developer.log(message.toString(), name: "onLaunch");
          _checkForSignInForVideoCall();
        },
        // When app is in background and accepts notification
        onResume: (message) async {
          developer.log(message.toString(), name: "onResume");
          _checkForSignInForVideoCall();
        },
      );
      prefs = await SharedPreferences.getInstance();
      String token = await _firebaseMessaging.getToken();
      prefs.setString("token", token);
      developer.log(token.toString(), name: "TOKEN");
      _initialized = true;
    }
  }

  // Do not directly open Video call if user isn't sign in
  _checkForSignInForVideoCall() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isLogin') &&
        prefs.getInt('isLogin') == 1 &&
        prefs.getInt('isLogin') != null) {
      navigatorKey.currentState.pushNamed('/videocall');
    }
    // Check on which platform it is running
    if (Platform.isAndroid) {
      developer.log("Android Platfrom");
    } else if (Platform.isIOS) {
      developer.log("IOS Platfrom");
    }
  }
}
