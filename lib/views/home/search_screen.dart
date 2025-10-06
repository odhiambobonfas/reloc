import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:reloc/core/network/api_client.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiClient _api = ApiClient();
  Timer? _debounce;
  List<Map<String, dynamic>> _allPosts = [];
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAllPosts();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAllPosts() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await _api.get('/posts');
      _allPosts = (data as List).cast<Map<String, dynamic>>();
      _results = _allPosts;
    } catch (e) {
      _error = 'Failed to load posts: $e';
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _controller.text.toLowerCase().trim();
      setState(() {
        if (q.isEmpty) {
          _results = _allPosts;
        } else {
          _results = _allPosts.where((p) {
            final content = (p['content'] ?? '').toString().toLowerCase();
            final author = (p['author'] ?? '').toString().toLowerCase();
            final type = (p['type'] ?? '').toString().toLowerCase();
            return content.contains(q) || author.contains(q) || type.contains(q);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search posts, authors, types... ',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: () { _controller.clear(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchAllPosts,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Retry', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? const Center(child: Text('No results', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final p = _results[index];
                        final author = p['author'] ?? 'Anonymous';
                        final content = p['content'] ?? '';
                        final type = p['type'] ?? '';
                        return Card(
                          color: AppColors.navBar,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(type.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ),
                        );
                      },
                    ),
    );
  }
}
