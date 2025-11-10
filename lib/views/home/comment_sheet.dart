import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../services/user_service.dart';
import 'package:reloc/core/network/api_service.dart';

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

  // Responsive sizing methods
  double getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use the smaller dimension to ensure consistency
    final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    if (minDimension < 360) return baseSize * 0.8;  // Small phones
    if (minDimension < 400) return baseSize * 0.9;  // Medium phones
    if (minDimension < 500) return baseSize;        // Large phones
    return baseSize * 1.1;                          // Tablets
  }

  double getResponsivePadding(BuildContext context) {
    return getResponsiveSize(context, 16);
  }

  double getResponsiveAvatarSize(BuildContext context) {
    return getResponsiveSize(context, 36);
  }

  double getResponsiveIconSize(BuildContext context) {
    return getResponsiveSize(context, 20);
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
      final response = await ApiService.get('/posts/${widget.postId}/comments');

      if (response['success'] == true) {
        final List data = response['data'];
        print('Successfully fetched ${data.length} comments');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load comments: ${response['message']}');
        throw Exception("Failed to load comments: ${response['message']}");
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
      final response = await ApiService.post(
        '/posts/${widget.postId}/comments',
        body: {
          "user_id": user.uid,
          "content": text.trim(),
          if (parentCommentId != null) "parent_id": parentCommentId,
        },
        requiresAuth: true,
      );

      if (response['success']) {
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
        throw Exception("Server responded with status: ${response['statusCode']}");
      }
    } catch (e) {
      _showSnackBar("Failed to add comment: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: getResponsiveSize(context, 14),
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: getResponsivePadding(context),
          right: getResponsivePadding(context),
        ),
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

  Widget _buildAvatar(String name, {double? size}) {
    final avatarSize = size ?? getResponsiveAvatarSize(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: avatarSize,
      height: avatarSize,
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: avatarSize * 0.4, // Responsive font size based on avatar size
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

        return Container(
          margin: EdgeInsets.only(
            bottom: getResponsiveSize(context, 8),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indentation line for nested comments
                if (depth > 0)
                  Container(
                    width: getResponsiveSize(context, 24),
                    margin: EdgeInsets.only(right: getResponsiveSize(context, 8)),
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
                          SizedBox(width: getResponsiveSize(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: getResponsiveSize(context, 15),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: getResponsiveSize(context, 8)),
                                    Text(
                                      '· $timestamp',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: getResponsiveSize(context, 12),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: getResponsiveSize(context, 4)),
                                Text(
                                  comment['content'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: getResponsiveSize(context, 14),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (depth < maxDepth)
                            IconButton(
                              icon: Icon(
                                Icons.reply, 
                                size: getResponsiveIconSize(context),
                              ),
                              color: Colors.white70,
                              onPressed: () => _startReply(comment, userName),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: getResponsiveSize(context, 32),
                                minHeight: getResponsiveSize(context, 32),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: getResponsiveSize(context, 8)),

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
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    final avatarSize = getResponsiveAvatarSize(context);
    
    return Container(
      padding: EdgeInsets.all(getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
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
              padding: EdgeInsets.symmetric(
                horizontal: getResponsivePadding(context),
                vertical: getResponsiveSize(context, 8),
              ),
              margin: EdgeInsets.only(bottom: getResponsiveSize(context, 8)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(getResponsiveSize(context, 8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply, 
                    color: AppColors.primary, 
                    size: getResponsiveIconSize(context),
                  ),
                  SizedBox(width: getResponsiveSize(context, 8)),
                  Expanded(
                    child: Text(
                      "Replying to $replyingToUserName",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: getResponsiveSize(context, 12),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close, 
                      color: AppColors.primary, 
                      size: getResponsiveIconSize(context),
                    ),
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
              SizedBox(width: getResponsiveSize(context, 12)),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: avatarSize,
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                      fontSize: getResponsiveSize(context, 14),
                    ),
                    decoration: InputDecoration(
                      hintText: replyingToUserName != null
                          ? "Write your reply..."
                          : "Add a comment…",
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: getResponsiveSize(context, 14),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(getResponsiveSize(context, 20)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.black.withOpacity(0.3),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: getResponsivePadding(context),
                        vertical: getResponsiveSize(context, 12),
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
              ),
              SizedBox(width: getResponsiveSize(context, 8)),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _commentController,
                builder: (context, value, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: value.text.trim().isNotEmpty
                        ? Container(
                            width: avatarSize,
                            height: avatarSize,
                            child: IconButton(
                              icon: Icon(
                                Icons.send, 
                                color: AppColors.primary,
                                size: getResponsiveIconSize(context),
                              ),
                              onPressed: () => _postComment(
                                _commentController.text.trim(),
                                parentCommentId: replyingToCommentId,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(context, 20)),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: avatarSize,
                            height: avatarSize,
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
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(getResponsivePadding(context)),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline, 
                    color: AppColors.primary, 
                    size: getResponsiveIconSize(context),
                  ),
                  SizedBox(width: getResponsiveSize(context, 12)),
                  Text(
                    "Comments",
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color ?? Colors.white,
                      fontSize: getResponsiveSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: commentsFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.hasData ? snapshot.data!.length : 0;
                      return Text(
                        '$count',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                          fontSize: getResponsiveSize(context, 16),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: getResponsiveSize(context, 16)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close, 
                      color: theme.iconTheme.color ?? Colors.white70, 
                      size: getResponsiveIconSize(context),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(getResponsiveSize(context, 12)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: getResponsivePadding(context),
                      vertical: getResponsiveSize(context, 8),
                    ),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: getResponsiveSize(context, 4),
                      ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          SizedBox(height: getResponsiveSize(context, 16)),
          Text(
            'Loading comments...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
              fontSize: getResponsiveSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(getResponsivePadding(context) * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: getResponsiveSize(context, 48),
            ),
            SizedBox(height: getResponsiveSize(context, 16)),
            Text(
              "Unable to load comments",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
                fontSize: getResponsiveSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getResponsiveSize(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getResponsivePadding(context)),
              child: Text(
                error.toString(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white54,
                  fontSize: getResponsiveSize(context, 14),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: getResponsiveSize(context, 24)),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  commentsFuture = _fetchComments();
                });
              },
              icon: Icon(Icons.refresh, size: getResponsiveIconSize(context)),
              label: Text(
                "Try Again",
                style: TextStyle(
                  fontSize: getResponsiveSize(context, 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: getResponsivePadding(context) * 1.5,
                  vertical: getResponsiveSize(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(getResponsivePadding(context) * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Theme.of(context).hintColor,
              size: getResponsiveSize(context, 64),
            ),
            SizedBox(height: getResponsiveSize(context, 16)),
            Text(
              "No comments yet",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.white70,
                fontSize: getResponsiveSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: getResponsiveSize(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getResponsivePadding(context)),
              child: Text(
                "Start the conversation by adding\nthe first comment",
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: getResponsiveSize(context, 14),
                ),
                textAlign: TextAlign.center,
              ),
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