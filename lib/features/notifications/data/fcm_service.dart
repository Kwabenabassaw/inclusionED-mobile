import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // 2. Get FCM token
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(uid, token);
      }

      // 3. Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(uid, newToken);
      });
      
      // 4. Foreground messages handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          debugPrint('Message notification: ${message.notification?.title} - ${message.notification?.body}');
        }
      });
      
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
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
}
