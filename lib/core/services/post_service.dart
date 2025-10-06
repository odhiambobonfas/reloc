import 'package:reloc/core/network/api_service.dart';
import 'package:reloc/models/post_model.dart';
import 'dart:io';

class PostService {
  static Future<List<PostModel>> fetchPosts() async {
    try {
      final result = await ApiService.get('/posts');
      if (result['success'] == true && result['data'] is List) {
        final data = result['data'] as List;
        return data.map((post) => PostModel.fromMap(post)).toList();
      }
      throw Exception(result['message'] ?? 'Failed to load posts');
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  static Future<void> toggleLike(String postId, String userId) async {
    try {
      await ApiService.post('/posts/$postId/like', body: {'userId': userId});
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  static Future<PostModel> createPost({
    required String content,
    File? mediaFile,
    String? mediaType,
    List<String>? tags,
    String? location,
    required String uid,
    required String author,
    String? category,
  }) async {
    try {
      Map<String, String> fields = {
        'uid': uid,
        'author': author,
        'content': content,
        'is_video': (mediaType == 'video').toString(),
      };

      if (category != null) {
        fields['type'] = category;
      } else {
        fields['type'] = 'general'; // Default category
      }

      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags.join(',');
      }
      if (location != null) {
        fields['location'] = location;
      }
      if (mediaType != null) {
        fields['media_type'] = mediaType;
      }

      Map<String, dynamic> result;
      if (mediaFile != null) {
        result = await ApiService.uploadFile(
          '/posts',
          filePath: mediaFile.path,
          fieldName: 'media',
          additionalFields: fields,
        );
      } else {
        result = await ApiService.post('/posts', body: fields);
      }

      if (result['success'] == true && result['post'] != null) {
        return PostModel.fromMap(result['post']);
      }
      throw Exception(result['message'] ?? 'Failed to create post');
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
}
