import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:reloc/views/chat/chat_screen.dart';

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
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.navBar,
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
            return const Center(
              child:
                  Text('No chats found.', style: TextStyle(color: Colors.white70)),
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
              final lastMessage = data['lastMessage'] ?? '';
              final time = (data['timestamp'] as Timestamp?)?.toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final otherName = userData['name'] ?? 'User';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    tileColor: AppColors.navBar,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    title: Text(otherName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                    ),
                    trailing: Text(
                      time != null
                          ? "${time.hour}:${time.minute.toString().padLeft(2, '0')}"
                          : '',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            otherUserName: otherName,
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
}
