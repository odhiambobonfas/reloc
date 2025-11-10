import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:reloc/views/chat/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChats() {
    return firestore
        .collection('chats')
        .where('users', arrayContains: currentUser?.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  String _getLastMessagePreview(Map<String, dynamic> data) {
    final lastMessage = data['lastMessage'] ?? '';
    final messageType = data['lastMessageType'] ?? 'text';
    
    switch (messageType) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'emoji':
        return '${data['lastMessage']}';
      case 'reply':
        return '↩️ ${data['lastMessage']}';
      default:
        return lastMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navBar,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a conversation with someone!',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final users = List<String>.from(data['users']);
              final otherUserId = users.firstWhere((id) => id != currentUser!.uid);
              final lastMessage = _getLastMessagePreview(data);
              final time = (data['lastMessageTime'] as Timestamp?)?.toDate();
              final unreadCount = data['unreadCount']?[currentUser!.uid] ?? 0;
              final isOnline = data['userStatus']?[otherUserId]?['isOnline'] ?? false;
              final lastSeen = data['userStatus']?[otherUserId]?['lastSeen'];

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final otherName = userData['name'] ?? userData['displayName'] ?? 'User';
                  final profilePic = userData['profilePic'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tileColor: AppColors.navBar,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                            child: profilePic == null
                                ? Icon(Icons.person, color: AppColors.primary)
                                : null,
                          ),
                          if (isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.navBar, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            time != null ? timeago.format(time) : '',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: TextStyle(
                                color: unreadCount > 0 ? AppColors.primary : Colors.white70,
                                fontSize: 14,
                                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              otherUserId: otherUserId,
                              otherUserName: otherName,
                            ),
                          ),
                        ).then((_) {
                          // Mark as read when returning from chat
                          firestore.collection('chats').doc(chat.id).update({
                            'unreadCount.$currentUser': 0,
                          });
                        });
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}