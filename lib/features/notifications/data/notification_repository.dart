import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';
import 'package:inclusive_ed_student/shared/models/notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  Stream<List<Notification>> watchNotifications(String recipientId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Notification.fromJson(data);
            }).toList());
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'read': true});
  }

  Future<void> markAllAsRead(String recipientId) async {
    final query = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .where('read', isEqualTo: false)
        .get();

    if (query.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

final notificationsStreamProvider = StreamProvider<List<Notification>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value([]);
  
  return ref.watch(notificationRepositoryProvider).watchNotifications(user.uid);
});
