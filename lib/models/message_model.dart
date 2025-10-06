class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'].toString(),
      senderId: map['sender_uid'] ?? '',
      receiverId: map['receiver_uid'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['created_at']),
    );
  }
}
