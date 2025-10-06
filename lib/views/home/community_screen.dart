import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../services/user_service.dart';
import 'package:reloc/views/shared/message_screen.dart';
import '../../utils/media_utils.dart';

const String apiBaseUrl = "http://192.168.20.58:5000/api";

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<Map<String, dynamic>>> postsFuture;
  String? userId;
  final UserService _userService = UserService();
  final Map<String, String> _userNames = {};
  final Map<int, Future<List<Map<String, dynamic>>>> _commentFutures = {};
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Relocation Tips', 'Events', 'General'];

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: AppColors.navBar,
      child: Row(
        children: [
          const Icon(Icons.forum, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Text(
            "Community",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/post-as'),
            tooltip: "Create Post",
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('Initializing CommunityScreen...');
    postsFuture = fetchPosts();
    userId = FirebaseAuth.instance.currentUser?.uid;
    print('User ID: $userId');
  }

  Future<String> _getUserDisplayName(String uid) async {
    if (_userNames.containsKey(uid)) {
      return _userNames[uid]!;
    }

    try {
      final userDoc = await _userService.getUserById(uid);
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final displayName = userData['displayName'] ??
                          userData['name'] ??
                          userData['email'] ??
                          'User';
        _userNames[uid] = displayName;
        return displayName;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == uid) {
        final displayName = user?.displayName ?? user?.email ?? 'User';
        _userNames[uid] = displayName;
        return displayName;
      }
    } catch (e) {
      print('Error getting Firebase Auth user: $e');
    }

    _userNames[uid] = 'User';
    return 'User';
  }

  Future<Map<String, dynamic>> _getUserDetails(String uid) async {
    try {
      final userDoc = await _userService.getUserById(uid);
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }

    // Fallback to Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid == uid) {
      return {
        'name': user?.displayName ?? 'User',
        'email': user?.email ?? 'No email',
        'phone': 'Not provided',
        'company': 'Not provided',
        'role': 'user'
      };
    }

    return {
      'name': 'User',
      'email': 'No email',
      'phone': 'Not provided',
      'company': 'Not provided',
      'role': 'user'
    };
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      print('Fetching posts from: $apiBaseUrl/posts');
      final response = await http.get(Uri.parse('$apiBaseUrl/posts'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Successfully fetched ${data.length} posts');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load posts: ${response.statusCode}');
        throw Exception("Failed to load posts: ${response.statusCode}");
      }
    } catch (e) {
      print('Exception fetching posts: $e');
      throw Exception("Network error: $e");
    }
  }

  Future<void> _likePost(int postId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to like posts")),
      );
      return;
    }

    await http.post(
      Uri.parse('$apiBaseUrl/posts/$postId/like'),
      body: jsonEncode({'userId': userId}),
      headers: {"Content-Type": "application/json"},
    );

    setState(() {
      postsFuture = fetchPosts();
    });
  }

  Future<void> _savePost(int postId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to save posts")),
      );
      return;
    }

    try {
      final result = await ApiService.post('/posts/$postId/save', body: {'userId': userId}, requiresAuth: false);
      if (result['success'] == true) {
        final saved = result['saved'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saved ? "Post saved!" : "Post unsaved!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save post")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving post: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    if (!_commentFutures.containsKey(postId)) {
      _commentFutures[postId] = _fetchCommentsFromServer(postId);
    }
    return await _commentFutures[postId]!;
  }

  Future<List<Map<String, dynamic>>> _fetchCommentsFromServer(int postId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/posts/$postId/comments'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error fetching comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching comments: $e');
      return [];
    }
  }

  Future<void> _addComment(int postId, String content, {int? parentId}) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to comment")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/posts/$postId/comments'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        }),
      );

      if (response.statusCode == 201) {
        _commentFutures.remove(postId);
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add comment: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding comment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sharePost(String content) {
    Share.share(content, subject: "Check out this relocation post!");
  }

  void _showUserProfile(String authorId) async {
    final userDetails = await _getUserDetails(authorId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person, color: AppColors.primary),
            SizedBox(width: 8),
            Text("User Profile", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserDetailRow("Name", userDetails['name'] ?? 'User'),
              _buildUserDetailRow("Email", userDetails['email'] ?? 'No email'),
              _buildUserDetailRow("Phone", userDetails['phone'] ?? 'Not provided'),
              if (userDetails['role'] == 'mover')
                _buildUserDetailRow("Company", userDetails['company'] ?? 'Not provided'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _messageUser(String authorId, String authorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageScreen(
          receiverId: authorId,
          receiverName: authorName,
        ),
      ),
    );
  }

  void _showReplyDialog(int postId, Map<String, dynamic> parentComment) {
    final replyController = TextEditingController();
    final parentUserId = parentComment['user_id'] ?? 'User';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.reply, color: AppColors.primary),
          SizedBox(width: 8),
          Text("Reply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 12),
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<String>(
                      future: _getUserDisplayName(parentUserId),
                      builder: (context, nameSnapshot) {
                        return Text(
                          nameSnapshot.data ?? 'User',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(parentComment['content'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Your reply:", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: replyController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Write your reply...",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                _addComment(postId, replyController.text.trim(), parentId: parentComment['id']);
                Navigator.pop(context);
              }
            },
            child: const Text("Send Reply"),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMenu(String authorId, String content) {
    return FutureBuilder<String>(
      future: _getUserDisplayName(authorId),
      builder: (context, nameSnapshot) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: AppColors.navBar,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(children: [
                Icon(Icons.share, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Share', style: TextStyle(color: Colors.white)),
              ]),
            ),
            if (authorId != userId)
            const PopupMenuItem(
              value: 'message',
              child: Row(children: [
                Icon(Icons.message, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Message Privately', style: TextStyle(color: Colors.white)),
              ]),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(children: [
                Icon(Icons.flag, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Report', style: TextStyle(color: Colors.white)),
              ]),
            ),
          ],
          onSelected: (value) {
            if (value == 'share') {
              _sharePost(content);
            } else if (value == 'message') {
              _messageUser(authorId, nameSnapshot.data ?? 'User');
            }
          },
        );
      },
    );
  }

  Widget _buildCommentsSection(int postId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchComments(postId),
      builder: (context, commentSnapshot) {
        if (commentSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          );
        }

        if (commentSnapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(height: 8),
                const Text('Error loading comments', style: TextStyle(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() { _commentFutures.remove(postId); }),
                  child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        }

        final comments = commentSnapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comments.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${comments.length} comment${comments.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: comments.take(10).map((c) => _buildComment(c, postId)).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
                      SizedBox(width: 8),
                      Text('No comments yet. Be the first to comment!', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),
              ],
              _CommentInputField(
                onSend: (text) => _addComment(postId, text),
                placeholder: comments.isEmpty ? "Write the first comment..." : "Write a comment...",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComment(Map<String, dynamic> comment, int postId, {int depth = 0}) {
    final replies = (comment['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final commentUserId = comment['user_id'] ?? 'Anonymous';
    final timestamp = comment['created_at'] != null
        ? timeago.format(DateTime.parse(comment['created_at']))
        : 'Recently';
    const maxDepth = 4;

    return FutureBuilder<String>(
      future: _getUserDisplayName(commentUserId),
      builder: (context, nameSnapshot) {
        final userName = nameSnapshot.data ?? 'User';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (depth > 0)
                  Container(
                    width: 24,
                    margin: const EdgeInsets.only(right: 8),
                    child: CustomPaint(
                      painter: IndentationLinePainter(),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(userName),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        userName,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '· $timestamp',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment['content'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (depth < maxDepth)
                            IconButton(
                              icon: const Icon(Icons.reply, size: 16),
                              color: Colors.white70,
                              onPressed: () => _showReplyDialog(postId, comment),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (replies.isNotEmpty && depth < maxDepth)
                        Column(
                          children: replies
                              .map((reply) => _buildComment(
                                    reply,
                                    postId,
                                    depth: depth + 1,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      postsFuture = fetchPosts();
    });
    await postsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppColors.navBar,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category ? AppColors.primary : Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPosts,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading posts',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshPosts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 64, color: Colors.white54),
                            SizedBox(height: 16),
                            Text(
                              'No posts yet',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Be the first to share something!',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredPosts = _selectedCategory == 'All'
                        ? posts
                        : posts.where((post) => post['category'] == _selectedCategory).toList();

                    if (filteredPosts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_alt_outlined, size: 64, color: Colors.white54),
                            const SizedBox(height: 16),
                            Text(
                              'No posts in $_selectedCategory',
                              style: const TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try selecting a different category',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final postId = post['id'];
                        final authorId = post['user_id'] ?? 'Anonymous';
                        final content = post['content'] ?? '';
                        final mediaUrl = post['media_url'];
                        final fullMediaUrl = MediaUtils.getFullMediaUrl(mediaUrl);
                        final isVideo = MediaUtils.isVideo(mediaUrl);
                        final likes = post['likes'] ?? 0;
                        final timestamp = post['created_at'] != null
                            ? timeago.format(DateTime.parse(post['created_at']))
                            : "";

                        return Card(
                          color: AppColors.navBar,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppColors.primary.withOpacity(0.2),
                                          child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _showUserProfile(authorId),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder<String>(
                                                  future: _getUserDisplayName(authorId),
                                                  builder: (context, nameSnapshot) {
                                                    return Text(
                                                      nameSnapshot.data ?? 'User',
                                                      style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                Text(
                                                  timestamp,
                                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        _buildPostMenu(authorId, content),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (content.isNotEmpty)
                                      Text(
                                        content,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                                      ),
                                    if (mediaUrl != null && mediaUrl.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: isVideo
                                              ? VideoPostWidget(videoUrl: fullMediaUrl)
                                              : Image.network(
                                                  fullMediaUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 200,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[800],
                                                      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[800],
                                                      child: const Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.broken_image, color: Colors.white54, size: 48),
                                                            SizedBox(height: 8),
                                                            Text('Failed to load image', style: TextStyle(color: Colors.white54)),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: _ActionButton(
                                            icon: Icons.thumb_up_alt_outlined,
                                            label: '$likes',
                                            onPressed: () => _likePost(postId),
                                          ),
                                        ),
                                        Flexible(
                                          child: _ActionButton(
                                            icon: Icons.bookmark_outline,
                                            label: 'Save',
                                            onPressed: () => _savePost(postId),
                                          ),
                                        ),
                                        Flexible(
                                          child: _ActionButton(
                                            icon: Icons.comment_outlined,
                                            label: 'Comment',
                                            onPressed: () {},
                                          ),
                                        ),
                                        const Spacer(),
                                        _ActionButton(
                                          icon: Icons.share_outlined,
                                          label: 'Share',
                                          onPressed: () => _sharePost(content),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 1),
                              _buildCommentsSection(postId),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentInputField extends StatefulWidget {
  final Function(String) onSend;
  final String? placeholder;
  const _CommentInputField({required this.onSend, this.placeholder});

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _isComposing = _controller.text.isNotEmpty);
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      widget.onSend(text.trim());
      _controller.clear();
      setState(() => _isComposing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: widget.placeholder ?? "Write a comment...",
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _isComposing ? 1.0 : 0.0,
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
              onPressed: () => _handleSubmitted(_controller.text),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPostWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPostWidget({super.key, required this.videoUrl});

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _controller?.dispose();

      print('Initializing video: ${widget.videoUrl}');

      _controller = VideoPlayerController.network(
        widget.videoUrl,
        httpHeaders: {
          'User-Agent': 'RelocApp/1.0',
          'Accept': '*/*',
        },
      );

      _controller!.addListener(_onVideoStateChanged);

      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
          _retryCount = 0;
        });
        print('Video initialized successfully');
      }
    } catch (e) {
      print('Video initialization error: $e');

      if (mounted) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          print('Retrying video initialization (attempt $_retryCount)');
          await Future.delayed(Duration(seconds: _retryCount));
          _initializeVideo();
          return;
        }

        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Video loading timeout';
    } else if (error.toString().contains('404')) {
      return 'Video not found';
    } else if (error.toString().contains('403')) {
      return 'Access denied';
    } else if (error.toString().contains('network')) {
      return 'Network error';
    } else if (error.toString().contains('format')) {
      return 'Unsupported format';
    } else {
      return 'Failed to load video';
    }
  }

  void _onVideoStateChanged() {
    if (!mounted) return;

    final value = _controller!.value;
    if (value.hasError) {
      print('Video player error: ${value.errorDescription}');
      setState(() {
        _hasError = true;
        _errorMessage = value.errorDescription ?? 'Video playback error';
        _isInitializing = false;
      });
    }
  }

  Future<void> _retryVideo() async {
    _retryCount = 0;
    await _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _retryVideo,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializing) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Video not ready',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller != null) {
          setState(() {
            if (_isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
            _isPlaying = !_isPlaying;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
              if (!_isPlaying)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white54,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primary.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class IndentationLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Widget _buildAvatar(String name) {
  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0.4)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}
