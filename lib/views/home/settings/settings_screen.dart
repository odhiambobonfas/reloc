import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/views/home/settings/account.dart';
import 'package:reloc/views/home/settings/change_password.dart';
import 'package:reloc/views/home/settings/edit.dart';
import 'package:reloc/views/shared/notification_settings_screen.dart';
import 'package:reloc/views/shared/notifications_screen.dart';
import 'package:reloc/views/home/settings/settings_theme_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (uid != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text('Loading account status...'),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final role = (data?['role'] ?? 'resident') as String;
                final isVerified = (data?['isVerified'] ?? false) as bool;

                return ListTile(
                  leading: Icon(
                    role == 'mover' && isVerified ? Icons.verified : Icons.person_outline,
                    color: role == 'mover' && isVerified ? Colors.green : null,
                  ),
                  title: Text(
                    role == 'mover' && isVerified
                        ? 'Account status: Mover (approved)'
                        : 'Account status: ${role[0].toUpperCase()}${role.substring(1)}',
                  ),
                  subtitle: Text(isVerified ? 'Verified' : 'Pending approval'),
                );
              },
            ),
          ListTile(
            title: const Text('Edit Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Theme'),
            leading: const Icon(Icons.color_lens),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsThemeScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Reloc',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Reloc',
              );
            },
          ),
        ],
      ),
    );
  }
}
