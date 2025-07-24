import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int moversCount = 0;
  int residentsCount = 0;
  int adminCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final allUsers = usersSnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        moversCount = allUsers.where((u) => u['role'] == 'mover').length;
        residentsCount = allUsers.where((u) => u['role'] == 'resident').length;
        adminCount = allUsers.where((u) => u['role'] == 'admin').length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Insights'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: isLoading
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatTile('Total Movers', moversCount, Icons.directions_run),
                  _buildStatTile('Total Residents', residentsCount, Icons.home),
                  _buildStatTile('Admins', adminCount, Icons.security),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'More reports and charts coming soon...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatTile(String label, int count, IconData icon) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(label),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
