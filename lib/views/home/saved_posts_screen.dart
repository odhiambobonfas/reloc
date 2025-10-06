import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/core/network/api_service.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  late Future<List<Map<String, dynamic>>> _savedPostsFuture;

  @override
  void initState() {
    super.initState();
    _savedPostsFuture = _fetchSavedPosts();
  }

  Future<List<Map<String, dynamic>>> _fetchSavedPosts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    final result = await ApiService.get('/posts/saved?userId=$userId', requiresAuth: false);
    if (result['success'] == true && result['data'] is List) {
      return (result['data'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception(result['message'] ?? 'Failed to load saved posts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No saved posts'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _savedPostsFuture = _fetchSavedPosts());
              await _savedPostsFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final author = post['user_id'] ?? 'Anonymous';
                final content = post['content'] ?? '';
                final createdAt = post['created_at'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(author),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (content.isNotEmpty) Text(content),
                        if (createdAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              createdAt.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
