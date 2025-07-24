import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/message_model.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C853),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser?.uid)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages found'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;

              final otherUserId = (chatData['participants'] as List)
                  .firstWhere((id) => id != currentUser!.uid);

              // Parse the lastMessage using MessageModel
              final lastMessageData = chatData['lastMessage'] ?? {};
              final lastMessage = MessageModel.fromMap(lastMessageData);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(title: Text("User not found"));
                  }

                  final user = userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user['photoUrl']?.isNotEmpty == true
                            ? user['photoUrl']
                            : 'https://ui-avatars.com/api/?name=${user['name']}',
                      ),
                    ),
                    title: Text(user['name'] ?? 'User'),
                    subtitle: Text(lastMessage.content),
                    trailing: Text(
                      _formatTimestamp(lastMessage.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            chatId: chatId,
                            peerId: otherUserId,
                            peerName: user['name'],
                            peerPhotoUrl: user['photoUrl'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final isToday = dt.day == now.day && dt.month == now.month && dt.year == now.year;

    if (isToday) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.month}/${dt.day}';
    }
  }
}
