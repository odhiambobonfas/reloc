import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_colors.dart';
import 'post_dialog.dart';
import 'comment_sheet.dart';

const String apiBaseUrl = "http://192.168.100.76:5000/api";

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<Map<String, dynamic>>> postsFuture;
  String? userId;

  @override
  void initState() {
    super.initState();
    postsFuture = fetchPosts();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/posts'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  Future<void> _likePost(int postId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to like posts")),
      );
      return;
    }

    await http.post(Uri.parse('$apiBaseUrl/posts/$postId/like'),
        body: jsonEncode({'userId': userId}),
        headers: {"Content-Type": "application/json"});

    setState(() {
      postsFuture = fetchPosts();
    });
  }

  void _openComments(int postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navBar,
      isScrollControlled: true,
      builder: (_) => CommentSheet(postId: postId, currentUserId: userId),
    );
  }

  void _sharePost(String content) {
    Share.share(content, subject: "Check out this relocation post!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PostDialog(
                onPostCreated: () => setState(() => postsFuture = fetchPosts())),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No posts yet.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postId = post['id'];
              final author = post['author'] ?? 'Anonymous';
              final content = post['content'] ?? '';
              final mediaUrl = post['media_url'];
              final isVideo = post['is_video'] ?? false;
              final likes = post['likes'] ?? 0;
              final timestamp = post['timestamp'] != null
                  ? timeago.format(DateTime.parse(post['timestamp']))
                  : "";

              return Card(
                color: AppColors.navBar,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(author,
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold)),
                                Text(timestamp,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 12))
                              ]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(content,
                          style: const TextStyle(color: Colors.white)),
                      if (mediaUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: isVideo
                              ? VideoPostWidget(videoUrl: mediaUrl)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(mediaUrl,
                                      fit: BoxFit.cover),
                                ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up_alt_outlined,
                                color: Colors.white),
                            onPressed: () => _likePost(postId),
                          ),
                          Text('$likes',
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined,
                                color: Colors.white),
                            onPressed: () => _openComments(postId),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: Colors.white),
                            onPressed: () => _sharePost(content),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying ? _controller.pause() : _controller.play();
          _isPlaying = !_isPlaying;
        });
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
