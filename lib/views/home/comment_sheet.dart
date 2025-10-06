import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../services/user_service.dart';

const String apiBaseUrl = "http://192.168.20.58:5000/api";

class CommentSheet extends StatefulWidget {
  final int postId;
  final String? currentUserId;

  const CommentSheet({super.key, required this.postId, this.currentUserId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  late Future<List<Map<String, dynamic>>> commentsFuture;
  final TextEditingController _commentController = TextEditingController();
  String? replyingToCommentId;
  String? replyingToUserName;
  final UserService _userService = UserService();
  final Map<String, String> _userNames = {};
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    commentsFuture = _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
            userData['email']?.split('@').first ??
            'Anonymous User';
        _userNames[uid] = displayName;
        return displayName;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == uid) {
        final displayName =
            user?.displayName ?? user?.email?.split('@').first ?? 'User';
        _userNames[uid] = displayName;
        return displayName;
      }
    } catch (e) {
      print('Error getting Firebase Auth user: $e');
    }

    _userNames[uid] = 'Anonymous User';
    return 'Anonymous User';
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    try {
      print('Fetching comments for post ${widget.postId}');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/posts/${widget.postId}/comments'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Successfully fetched ${data.length} comments');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load comments: ${response.statusCode}');
        throw Exception("Failed to load comments: ${response.statusCode}");
      }
    } catch (e) {
      print('Exception fetching comments: $e');
      throw Exception("Network error: $e");
    }
  }

  Future<void> _postComment(String text, {String? parentCommentId}) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You need to log in to comment", isError: true);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/posts/${widget.postId}/comments'),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "user_id": user.uid,
          "content": text.trim(),
          if (parentCommentId != null) "parent_id": parentCommentId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Comment added successfully!", isError: false);
        setState(() {
          commentsFuture = _fetchComments();
          _commentController.clear();
          replyingToCommentId = null;
          replyingToUserName = null;
        });
        _commentFocusNode.unfocus();
        
        // Scroll to bottom after adding comment
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        throw Exception("Server responded with status: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Failed to add comment: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _startReply(Map<String, dynamic> comment, String userName) {
    setState(() {
      replyingToCommentId = comment['id'].toString();
      replyingToUserName = userName;
    });
    _commentController.clear();
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      replyingToCommentId = null;
      replyingToUserName = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  Widget _buildAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment, {int depth = 0}) {
    final replies =
        (comment['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final commentUserId = comment['user_id'] ?? 'Anonymous';
    final timestamp = comment['created_at'] != null
        ? timeago.format(DateTime.parse(comment['created_at']))
        : 'Recently';
    const maxDepth = 4;

    return FutureBuilder<String>(
      future: _getUserDisplayName(commentUserId),
      builder: (context, nameSnapshot) {
        final userName = nameSnapshot.data ?? 'User';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indentation line for nested comments
              if (depth > 0)
                Container(
                  width: 24,
                  margin: const EdgeInsets.only(right: 8),
                  child: CustomPaint(
                    painter: _IndentationLinePainter(),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatar(userName),
                        const SizedBox(width: 12),
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
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '· $timestamp',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment['content'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (depth < maxDepth)
                          IconButton(
                            icon: const Icon(Icons.reply, size: 18),
                            color: Colors.white70,
                            onPressed: () => _startReply(comment, userName),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nested Replies
                    if (replies.isNotEmpty && depth < maxDepth)
                      Column(
                        children: replies
                            .map((reply) => _buildCommentTile(
                                  reply,
                                  depth: depth + 1,
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Reply indicator
          if (replyingToUserName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Replying to $replyingToUserName",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, color: AppColors.primary, size: 16),
                  ),
                ],
              ),
            ),
          
          // Input field
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: _getUserDisplayName(FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  return _buildAvatar(snapshot.data ?? 'Me');
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: replyingToUserName != null
                        ? "Write your reply..."
                        : "Add a comment…",
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) => _postComment(
                    text.trim(),
                    parentCommentId: replyingToCommentId,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _commentController,
                builder: (context, value, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: value.text.trim().isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.send, color: AppColors.primary),
                            onPressed: () => _postComment(
                              _commentController.text.trim(),
                              parentCommentId: replyingToCommentId,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                          ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    "Comments",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: commentsFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.hasData ? snapshot.data!.length : 0;
                      return Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Comments List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  final comments = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildCommentTile(comments[index]),
                    ),
                  );
                },
              ),
            ),
            
            // Comment input (stays at bottom)
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _buildCommentInput(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading comments...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Unable to load comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  commentsFuture = _fetchComments();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              "No comments yet",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Start the conversation by adding\nthe first comment",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IndentationLinePainter extends CustomPainter {
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