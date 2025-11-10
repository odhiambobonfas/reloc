import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/core/network/api_service.dart';

class MessageService {
  /// Fetch list of conversations for current user
  /// Expected response: List of objects with keys:
  /// { id, otherUser: { id, name, photoUrl }, lastMessage: {...}, updatedAt }
  static Future<List<Map<String, dynamic>>> fetchConversations() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final result = await ApiService.get('/messages/conversations?uid=${currentUser.uid}', requiresAuth: true);
    if (result['success'] == true && result['data'] is List) {
      return (result['data'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception(result['message'] ?? 'Failed to load conversations');
  }

  /// Fetch messages in a conversation
  /// Expected response: List of message objects with keys matching MessageModel.fromMap
  static Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    final result = await ApiService.get('/messages/$chatId', requiresAuth: false);
    if (result['success'] == true && result['data'] is List) {
      return (result['data'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception(result['message'] ?? 'Failed to load messages');
  }

  /// Send a message to a conversation
  /// Expected body: { content, type?, receiverId? }
  static Future<bool> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    String? receiverId,
  }) async {
    final result = await ApiService.post(
      '/messages/$chatId/send',
      body: {
        'content': content,
        'type': type,
        if (receiverId != null) 'receiverId': receiverId,
      },
      requiresAuth: false,
    );
    return result['success'] == true;
  }
}


