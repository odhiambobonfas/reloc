import 'package:flutter/material.dart';
import 'package:reloc/core/network/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reloc/core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushNotifications = false;
  bool emailNotifications = false;
  bool smsNotifications = false;
  bool loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    if (_userId == null) {
      setState(() => loading = false);
      return;
    }
    try {
      final result = await ApiService.get('/notifications/settings/$_userId', requiresAuth: false);
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          pushNotifications = data['push'] ?? false;
          emailNotifications = data['email'] ?? false;
          smsNotifications = data['sms'] ?? false;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        debugPrint('Failed to fetch settings: ${result['message'] ?? result['error']}');
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> updateSettings() async {
    if (_userId == null) return;
    try {
      final result = await ApiService.put(
        '/notifications/settings/$_userId',
        body: {
          'push': pushNotifications,
          'email': emailNotifications,
          'sms': smsNotifications,
        },
        requiresAuth: false,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update settings')),
        );
      }
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        title: const Text("Notifications Settings"),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text(
                      "Push Notifications",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      "Get instant notifications on your device",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: pushNotifications,
                    onChanged: (val) => setState(() => pushNotifications = val),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text(
                      "Email Notifications",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      "Receive updates via email",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: emailNotifications,
                    onChanged: (val) => setState(() => emailNotifications = val),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text(
                      "SMS Notifications",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      "Get text message alerts",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: smsNotifications,
                    onChanged: (val) => setState(() => smsNotifications = val),
                    activeColor: AppColors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: updateSettings,
                    child: const Text("Save Settings"),
                  ),
                ),
              ],
            ),
    );
  }
}
