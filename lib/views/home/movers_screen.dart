import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import 'package:reloc/views/shared/message_screen.dart'; // 👈 import your message screen

class MoversScreen extends StatelessWidget {
  const MoversScreen({super.key});

  // ✅ Fetch all users where role == "mover"
  Future<List<Map<String, dynamic>>> _fetchMovers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'mover')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // 👈 include document ID for reference
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ReLoC Movers'), // ✅ updated name
        backgroundColor: AppColors.navBar,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMovers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final movers = snapshot.data;

          if (movers == null || movers.isEmpty) {
            return const Center(
              child: Text('No movers found', style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movers.length,
            itemBuilder: (context, index) {
              final mover = movers[index];
              final name = mover['name'] ?? 'Mover';
              final email = mover['email'] ?? 'No email';
              final phone = mover['phone'] ?? '';
              final photoUrl = mover['photoUrl']?.isNotEmpty == true
                  ? mover['photoUrl']
                  : 'https://ui-avatars.com/api/?name=$name';

              return Card(
                color: AppColors.navBar,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                    radius: 25,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(email, style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.message, color: AppColors.primary),
                    onPressed: () {
                      // ✅ Navigate to MessageScreen and pass mover details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessageScreen(
                            receiverId: mover['id'], // mover's user id
                            receiverName: name,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Optional: Navigate to mover detail screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
