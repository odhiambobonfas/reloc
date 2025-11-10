
class PostModel {
  final int id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String? mediaUrl;
  final bool isVideo;
  final int likes;
  final int comments;
  final int shares;
  final List<String> likedBy;
  final List<String> tags;
  final String? location;
  final String? category;
  final bool isPublic;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  PostModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    this.mediaUrl,
    this.isVideo = false,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.likedBy = const [],
    this.tags = const [],
    this.location,
    this.category,
    this.isPublic = true,
    this.isEdited = false,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      content: map['content'] ?? '',
      authorId: map['user_id'] ?? '',
      authorName: map['author'] ?? 'Anonymous',
      authorPhotoUrl: null, // Not provided by the backend
      mediaUrl: map['media_url'],
      isVideo: map['is_video'] ?? false,
      likes: map['likes'] ?? 0,
      comments: 0, // Not provided by the backend
      shares: 0, // Not provided by the backend
      likedBy: map['liked_by'] != null ? List<String>.from(map['liked_by']) : [],
      tags: [], // Not provided by the backend
      location: null, // Not provided by the backend
      category: map['type'],
      isPublic: true, // Assuming all posts from the backend are public
      isEdited: false, // Not provided by the backend
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      metadata: null, // Not provided by the backend
    );
  }

  PostModel copyWith({
    int? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? mediaUrl,
    bool? isVideo,
    int? likes,
    int? comments,
    int? shares,
    List<String>? likedBy,
    List<String>? tags,
    String? location,
    String? category,
    bool? isPublic,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isVideo: isVideo ?? this.isVideo,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      likedBy: likedBy ?? this.likedBy,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get isVideoFile => hasMedia && isVideo;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}