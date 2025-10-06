import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/core/network/api_service.dart';
import 'package:reloc/models/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final result = await ApiService.get('/notifications?user_id=${user.uid}');
      if (result['success'] == true && result['data'] is List) {
        final data = result['data'] as List;
        return data.map((notification) => NotificationModel.fromMap(notification)).toList();
      }
      throw Exception(result['message'] ?? 'Failed to load notifications');
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      await ApiService.put('/notifications/$notificationId/read?user_id=${user.uid}');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
