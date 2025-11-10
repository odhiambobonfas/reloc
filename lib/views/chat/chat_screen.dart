import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();

  Map<String, String>? replyingToMessage;
  bool showEmojiPicker = false;
  bool isUploading = false;

  // Common emojis for quick reactions
  final List<String> quickEmojis = ['😊', '😂', '😍', '😮', '😢', '👍', '❤️', '🔥'];

  Stream<QuerySnapshot> getMessages() {
    return firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String content,
    String type = 'text',
    String? mediaUrl,
    Map<String, dynamic>? replyTo,
  }) async {
    if (content.trim().isEmpty && type == 'text') return;

    final messageData = {
      'senderId': currentUser!.uid,
      'content': content,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [currentUser!.uid],
      'likes': [],
      'replyTo': replyTo,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    };

    try {
      // Add message to subcollection
      await firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      // Update chat document with last message info
      await firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': type == 'text' ? content : getMediaMessageText(type),
        'lastMessageType': type,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': currentUser!.uid,
        'unreadCount.${widget.otherUserId}': FieldValue.increment(1),
      });

      // Clear reply if any
      if (replyingToMessage != null) {
        setState(() {
          replyingToMessage = null;
        });
      }

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getMediaMessageText(String type) {
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'emoji':
        return '😊 Emoji';
      default:
        return 'Media';
    }
  }

  Future<void> likeMessage(String messageId, List<String> currentLikes) async {
    final isLiked = currentLikes.contains(currentUser!.uid);
    
    await firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUser!.uid])
          : FieldValue.arrayUnion([currentUser!.uid]),
    });
  }

  Future<void> pickAndSendImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => isUploading = true);
      try {
        // TODO: Implement your file upload logic here
        // For now, we'll simulate upload
        await Future.delayed(const Duration(seconds: 2));
        await sendMessage(
          content: 'Image',
          type: 'image',
          mediaUrl: pickedFile.path, // This should be the uploaded URL
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  void showMessageOptions(BuildContext context, String messageId, Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply, color: Colors.white),
            title: const Text('Reply', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                replyingToMessage = {
                  'id': messageId,
                  'content': message['content'],
                  'sender': message['senderId'],
                };
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.thumb_up, color: Colors.white),
            title: const Text('Like', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              likeMessage(messageId, List<String>.from(message['likes'] ?? []));
            },
          ),
          if (message['senderId'] == currentUser!.uid)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Implement delete functionality
              },
            ),
        ],
      ),
    );
  }

  Widget buildMessageBubble(DocumentSnapshot messageDoc) {
    final message = messageDoc.data() as Map<String, dynamic>;
    final isMe = message['senderId'] == currentUser!.uid;
    final messageType = message['type'] ?? 'text';
    final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
    final likes = List<String>.from(message['likes'] ?? []);
    final isLiked = likes.contains(currentUser!.uid);
    final replyTo = message['replyTo'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => showMessageOptions(context, messageDoc.id, message),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.navBar,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply preview
                    if (replyTo != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              replyTo['sender'] == currentUser!.uid ? 'You' : widget.otherUserName,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              replyTo['content'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                    // Message content
                    if (messageType == 'text')
                      Text(
                        message['content'],
                        style: TextStyle(
                          color: isMe ? Colors.black : Colors.white,
                          fontSize: 16,
                        ),
                      ),

                    if (messageType == 'image')
                      Column(
                        children: [
                          Image.network(
                            message['mediaUrl'],
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.broken_image, size: 50),
                          ),
                          const SizedBox(height: 4),
                          const Text('📷 Photo', style: TextStyle(color: Colors.white70)),
                        ],
                      ),

                    if (messageType == 'emoji')
                      Text(
                        message['content'],
                        style: const TextStyle(fontSize: 32),
                      ),

                    // Timestamp and likes
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timestamp != null)
                          Text(
                            timeago.format(timestamp),
                            style: TextStyle(
                              color: isMe ? Colors.black54 : Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        if (likes.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                likes.length.toString(),
                                style: TextStyle(
                                  color: isMe ? Colors.black54 : Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickEmojis() {
    return Container(
      height: 60,
      color: AppColors.navBar,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickEmojis.length,
        itemBuilder: (context, index) {
          return IconButton(
            onPressed: () {
              sendMessage(content: quickEmojis[index], type: 'emoji');
              setState(() => showEmojiPicker = false);
            },
            icon: Text(
              quickEmojis[index],
              style: const TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Online',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.navBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Start a conversation with ${widget.otherUserName}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessageBubble(messages[index]);
                  },
                );
              },
            ),
          ),

          // Reply preview
          if (replyingToMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.navBar.withOpacity(0.8),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${replyingToMessage!['sender'] == currentUser!.uid ? 'yourself' : widget.otherUserName}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          replyingToMessage!['content'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.white70,
                    onPressed: () {
                      setState(() {
                        replyingToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Quick emojis
          if (showEmojiPicker) buildQuickEmojis(),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.navBar,
            child: Row(
              children: [
                // Emoji button
                IconButton(
                  icon: Icon(
                    showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() => showEmojiPicker = !showEmojiPicker);
                  },
                ),

                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  onPressed: pickAndSendImage,
                ),

                // Message input
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (text) {
                      if (replyingToMessage != null) {
                        sendMessage(
                          content: text,
                          replyTo: {
                            'id': replyingToMessage!['id'],
                            'content': replyingToMessage!['content'],
                            'sender': replyingToMessage!['sender'],
                          },
                        );
                      } else {
                        sendMessage(content: text);
                      }
                      messageController.clear();
                    },
                  ),
                ),

                // Send button
                if (isUploading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () {
                      final text = messageController.text.trim();
                      if (text.isNotEmpty) {
                        if (replyingToMessage != null) {
                          sendMessage(
                            content: text,
                            replyTo: {
                              'id': replyingToMessage!['id'],
                              'content': replyingToMessage!['content'],
                              'sender': replyingToMessage!['sender'],
                            },
                          );
                        } else {
                          sendMessage(content: text);
                        }
                        messageController.clear();
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}