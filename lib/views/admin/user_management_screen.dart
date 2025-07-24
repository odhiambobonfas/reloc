import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String selectedRole = 'all';

  @override
  Widget build(BuildContext context) {
    final userQuery = selectedRole == 'all'
        ? FirebaseFirestore.instance.collection('users')
        : FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: selectedRole);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildRoleFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['photoUrl'] ??
                            'https://ui-avatars.com/api/?name=${user['name'] ?? 'User'}'),
                      ),
                      title: Text(user['name'] ?? user['email'] ?? 'User'),
                      subtitle: Text('Role: ${user['role'] ?? 'unknown'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(docs[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: const InputDecoration(
          labelText: 'Filter by Role',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All')),
          DropdownMenuItem(value: 'mover', child: Text('Movers')),
          DropdownMenuItem(value: 'resident', child: Text('Residents')),
          DropdownMenuItem(value: 'admin', child: Text('Admins')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => selectedRole = value);
          }
        },
      ),
    );
  }

  void _confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('users').doc(userId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            },
          ),
        ],
      ),
    );
  }
}
