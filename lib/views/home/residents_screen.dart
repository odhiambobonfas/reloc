import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import 'package:reloc/views/shared/message_screen.dart'; // Import your MessageScreen

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({super.key});

  // ✅ Fetch all users where role == "resident"
  Future<List<Map<String, dynamic>>> _fetchResidents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'resident')
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
        title: const Text('Residents'),
        backgroundColor: AppColors.navBar,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchResidents(),
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

          final residents = snapshot.data;

          if (residents == null || residents.isEmpty) {
            return const Center(
              child: Text('No residents found', style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: residents.length,
            itemBuilder: (context, index) {
              final resident = residents[index];
              final name = resident['name'] ?? 'Resident';
              final email = resident['email'] ?? 'No email';
              final phone = resident['phone'] ?? '';
              final photoUrl = resident['photoUrl']?.isNotEmpty == true
                  ? resident['photoUrl']
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
                    icon: const Icon(Icons.message, color: AppColors.accent),
                    onPressed: () {
                      // ✅ Navigate to MessageScreen with resident details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessageScreen(
                            receiverId: resident['id'], // resident user id
                            receiverName: name,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Optional: Navigate to resident detail screen
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
