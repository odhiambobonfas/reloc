import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';

class MessageScreen extends StatefulWidget {
  final String receiverId; // from residents or movers
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

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  late String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = _auth.currentUser?.uid ?? "";
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final result = await ApiService.get('/messages?userId=$_currentUid&receiverId=${widget.receiverId}');
      if (result['success'] == true) {
        final List data = result['data'];
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? "Failed to fetch messages");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching messages: $e")));
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final result = await ApiService.post('/messages', body: {
        "senderId": _currentUid,
        "receiverId": widget.receiverId,
        "content": text,
      });

      if (result['success'] == true) {
        _controller.clear();
        _fetchMessages();
      } else {
        throw Exception(result['message'] ?? "Failed to send message");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error sending message: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: AppColors.navBar,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['senderId'] == _currentUid;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.greenAccent
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['content'] ?? "",
                            style: TextStyle(
                                color: isMe ? Colors.black : Colors.white),
                          ),
                        ),
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(8))),
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
