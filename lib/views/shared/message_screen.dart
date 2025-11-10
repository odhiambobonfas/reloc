import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/models/message_model.dart';
import '../../core/constants/app_colors.dart';
import '../../services/message_service.dart';
import '../../widgets/common/message_bubble.dart';

class MessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const MessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<List<Map<String, dynamic>>> _messagesFuture;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final uids = [currentUser.uid, widget.receiverId]..sort();
      _chatId = uids.join('_');
      _messagesFuture = MessageService.fetchMessages(_chatId);
    } else {
      // Handle user not logged in
      _chatId = '';
      _messagesFuture = Future.value([]);
    }
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _messagesFuture = MessageService.fetchMessages(_chatId);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final success = await MessageService.sendMessage(
        chatId: _chatId,
        content: text,
        receiverId: widget.receiverId,
      );
      if (success) {
        _controller.clear();
        _fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send message")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: AppColors.navBar,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUid;

                    return MessageBubble(
                      message: msg['content'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.greenAccent),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}