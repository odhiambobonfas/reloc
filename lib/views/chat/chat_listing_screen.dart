import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_detail_screen.dart';
import 'package:reloc/services/message_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Map<String, dynamic>>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = MessageService.fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C853),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(child: Text('No messages found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _conversationsFuture = MessageService.fetchConversations());
              await _conversationsFuture;
            },
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatId = chat['id']?.toString() ?? '';
                final other = (chat['otherUser'] ?? {}) as Map<String, dynamic>;
                final last = (chat['lastMessage'] ?? {}) as Map<String, dynamic>;

                final name = other['name'] ?? 'User';
                final photoUrl = other['photoUrl'] ?? '';
                final lastContent = last['content'] ?? last['text'] ?? '';
                final lastTimestamp = last['timestamp'];
                final postContent = last['postContent'] as String?;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      photoUrl.isNotEmpty ? photoUrl : 'https://ui-avatars.com/api/?name=$name',
                    ),
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (postContent != null)
                        Text(
                          'Re: ${postContent.length > 30 ? postContent.substring(0, 30) + '...' : postContent}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      Text(lastContent),
                    ],
                  ),
                  trailing: Text(
                    lastTimestamp != null ? _formatTimestampServer(lastTimestamp) : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          chatId: chatId,
                          peerId: other['id']?.toString() ?? '',
                          peerName: name,
                          peerPhotoUrl: photoUrl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTimestampServer(dynamic ts) {
    DateTime dt;
    if (ts is String) {
      dt = DateTime.tryParse(ts) ?? DateTime.now();
    } else if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      dt = DateTime.now();
    }
    final now = DateTime.now();
    final isToday = dt.day == now.day && dt.month == now.month && dt.year == now.year;
    if (isToday) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.month}/${dt.day}';
    }
  }
}
