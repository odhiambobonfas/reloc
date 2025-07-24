import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, system }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final Timestamp timestamp;
  final bool isSeen;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isSeen = false,
  });

  /// Converts Firestore document to MessageModel
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: _parseMessageType(data['type']),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isSeen: data['isSeen'] ?? false,
    );
  }

  /// Converts MessageModel to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp,
      'isSeen': isSeen,
    };
  }

  /// Helper to parse string to enum
  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  /// Clone with changes
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    Timestamp? timestamp,
    bool? isSeen,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: _parseMessageType(map['type']),
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isSeen: map['isSeen'] ?? false,
    );
  }
}