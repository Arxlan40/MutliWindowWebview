import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// -----------------------------------------
/// Push notification
/// -----------------------------------------
class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  /// -----------------------------------------
  /// Initializing the fcm token
  /// -----------------------------------------
  Future initialise(BuildContext context) async {
    var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      // request permissions if we're on android

      await _fcm.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );
      getmessages(context);
      _fcm.getToken().then((token) async {
        print(token);
      });
    }
    getmessages(context);

    _fcm.getToken().then((token) async {
      print(token);
    });
  }

  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  Future<void> _showNotification(
      int notificationId,
      String notificationTitle,
      String notificationContent,
      String payload, {
        String channelId = '1234',
        String channelTitle = 'Android Channel',
        String channelDescription = 'Default Android Channel for notifications',
        Priority notificationPriority = Priority.High,
        Importance notificationImportance = Importance.Max,
      }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription,
      playSound: false,
      importance: notificationImportance,
      priority: notificationPriority,
    );
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        playSound: true,

        showProgress: true,
        priority: Priority.High,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  Future<dynamic> onSelectNotification(String payload) async {}

  /// -----------------------------------------
  /// getting message function
  /// -----------------------------------------
  Future getmessages(BuildContext context) {
    _fcm.configure(
      // Called when the app is in the foreground and we receive a push notification
      onMessage: (Map<String, dynamic> message) async {
        print('onMesage: $message');
        showNotification(
            message['notification']['title'], message['notification']['body']);

      },
      // Called when the app has been closed comlpetely and it's opened
      // from the push notification.
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _serialiseAndNavigate(message, context);
      },
      // Called when the app is in the background and it's opened
      // from the push notification.
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _serialiseAndNavigate(message, context);
      },
    );
  }

  _serialiseAndNavigate(
      Map<String, dynamic> message, BuildContext context) async {
    //var notificationData = message['data'];
  }
}