import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

const String apiBaseUrl = "http://192.168.100.76:5000/api";

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

  @override
  void initState() {
    super.initState();
    commentsFuture = _fetchComments();
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    final response =
        await http.get(Uri.parse('$apiBaseUrl/posts/${widget.postId}/comments'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load comments");
    }
  }

  Future<void> _postComment(String text, {String? parentCommentId}) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to comment")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/posts/${widget.postId}/comments'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "author": user.displayName ?? "Anonymous",
        "text": text.trim(),
        "parent_comment_id": parentCommentId
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        commentsFuture = _fetchComments();
        _commentController.clear();
        replyingToCommentId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add comment")),
      );
    }
  }

  Widget _buildCommentTile(Map<String, dynamic> comment, {int level = 0}) {
    final replies = (comment['replies'] as List?) ?? [];
    return Padding(
      padding: EdgeInsets.only(left: level * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(comment['author'],
                style: const TextStyle(color: AppColors.primary)),
            subtitle:
                Text(comment['text'], style: const TextStyle(color: Colors.white)),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  replyingToCommentId =
                      replyingToCommentId == comment['id'].toString()
                          ? null
                          : comment['id'].toString();
                });
              },
              child: Text(
                replyingToCommentId == comment['id'].toString()
                    ? "Cancel"
                    : "Reply",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          if (replyingToCommentId == comment['id'].toString())
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Write a reply...",
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () => _postComment(_commentController.text,
                        parentCommentId: comment['id'].toString()),
                  )
                ],
              ),
            ),
          ...replies
              .map((reply) => _buildCommentTile(reply, level: level + 1))
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text("Comments",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(color: Colors.white30),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No comments yet",
                          style: TextStyle(color: Colors.white70)));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) =>
                      _buildCommentTile(comments[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () =>
                    _postComment(_commentController.text.trim()),
              )
            ],
          )
        ],
      ),
    );
  }
}
