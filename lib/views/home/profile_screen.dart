import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:reloc/views/home/home_ads/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> userData;

  @override
  void initState() {
    super.initState();
    userData = FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: userData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final name = data['name'] ?? 'Your Name';
            final email = user?.email ?? 'your@email.com';
            final photo = data['photoUrl'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[700],
                        backgroundImage: photo != null ? NetworkImage(photo) : null,
                        child: photo == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Profile Completion Progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.navBar,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Complete your profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Improve your visibility by adding missing details.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Profile Actions
                  _buildOptionTile(Icons.edit_note, 'Edit Profile', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  }),
                  _buildOptionTile(Icons.bookmark_outline, 'Saved Posts', () {
                    // Navigate to saved items
                  }),
                  _buildOptionTile(Icons.settings, 'Settings', () {
                    // Navigate to settings
                  }),
                  _buildOptionTile(Icons.logout, 'Logout', () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
          onTap: onTap,
        ),
        const Divider(color: Colors.white24, height: 1),
      ],
    );
  }
}
