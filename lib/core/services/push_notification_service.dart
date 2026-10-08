import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// 🔴 Background handler humesha class ke bahar (top-level) hona chahiye
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background Message Received: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. OS se Permission Maango (Android 13+ & iOS ke liye zaroori)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else {
      debugPrint('⚠️ User declined notification permission');
    }

    // 2. Background Message Setup
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Get FCM Token (Yeh token hume specific user ko message bhejne me kaam aayega)
    try {
      String? token = await _fcm.getToken();
      debugPrint("🔥 FCM Registration Token: $token");
      // Future upgrade: Is token ko Firebase User Profile me save karwa denge
    } catch (e) {
      debugPrint("Failed to get FCM token: $e");
    }

    // 4. Foreground Message Listener (Jab user app chala raha ho tab notification aaye)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null) {
        debugPrint('Notification Title: ${message.notification?.title}');
        debugPrint('Notification Body: ${message.notification?.body}');
      }
    });
  }
}