import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized before using it in the background
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Function(String, String?)? onNotificationTapped;

  Future<void> setupFCM(String uid) async {
    // 1. Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    } else {
      debugPrint('User declined or has not accepted notification permissions');
    }

    // 2. Initialize local notifications for foreground banner
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleRouting(response.payload!);
        }
      },
    );

    // 3. Get FCM token
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(uid, token);
      }

      // 4. Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(uid, newToken);
      });
      
      // 5. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 6. Foreground messages handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });
      
      // 7. Handle tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageTap(message);
      });
      
      // 8. Handle tap when app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        // Delay navigation slightly to ensure router is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleMessageTap(initialMessage);
        });
      }
      
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  void setOnNotificationTapped(Function(String type, String? referenceId) callback) {
    onNotificationTapped = callback;
  }

  void _handleMessageTap(RemoteMessage message) {
    if (message.data.containsKey('type')) {
      final type = message.data['type'] as String;
      final referenceId = message.data['referenceId'] as String?;
      onNotificationTapped?.call(type, referenceId);
    }
  }

  void _handleRouting(String payload) {
    // Payload can be a simple string encoding type:referenceId
    final parts = payload.split(':');
    if (parts.isNotEmpty) {
      final type = parts[0];
      final referenceId = parts.length > 1 ? parts[1] : null;
      onNotificationTapped?.call(type, referenceId);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] as String? ?? 'system';
    final referenceId = message.data['referenceId'] as String? ?? '';
    final payload = '$type:$referenceId';

    const androidDetails = AndroidNotificationDetails(
      'inclusioned_main_channel',
      'Important Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: payload,
    );
  }

  Future<void> _saveTokenToFirestore(String uid, String token) async {
    try {
      await _firestore.collection('fcmTokens').doc(token).set({
        'uid': uid,
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM Token saved to Firestore for $uid');
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('fcmTokens').doc(token).delete();
        await _messaging.deleteToken();
        debugPrint('FCM Token deleted from Firestore and device');
      }
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
