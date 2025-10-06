import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.navBar,
      ),
      body: const FirestoreSearchBar(collectionName: 'users'),
    );
  }
}

class FirestoreSearchBar extends StatefulWidget {
  final String collectionName;

  const FirestoreSearchBar({super.key, required this.collectionName});

  @override
  State<FirestoreSearchBar> createState() => _FirestoreSearchBarState();
}

class _FirestoreSearchBarState extends State<FirestoreSearchBar> {
  String _searchText = '';
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  void _searchFirestore(String text) async {
    setState(() {
      _searchText = text;
      _isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection(widget.collectionName)
        .orderBy('name')
        .startAt([text])
        .endAt(['$text\uf8ff'])
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.navBar,
              prefixIcon: const Icon(Icons.search, color: AppColors.accent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _searchFirestore,
          ),
        ),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_searchText.isNotEmpty)
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text('No results found', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      final name = item['name'] ?? 'Unknown';
                      final email = item['email'] ?? 'No email';
                      final photoUrl = item['photoUrl']?.isNotEmpty == true
                          ? item['photoUrl']
                          : 'https://ui-avatars.com/api/?name=$name';

                      return Card(
                        color: AppColors.navBar,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(photoUrl)),
                          title: Text(name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(email, style: const TextStyle(color: Colors.white70)),
                          onTap: () {
                            // TODO: Add profile or chat navigation here
                          },
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
