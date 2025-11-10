class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}