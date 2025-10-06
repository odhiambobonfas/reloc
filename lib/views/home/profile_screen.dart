import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reloc/core/constants/app_colors.dart';
import 'package:reloc/views/home/settings/edit.dart';
import 'package:reloc/routes/app_routes.dart';
import 'package:reloc/views/home/payment/payment.dart';
import 'package:reloc/views/home/payment/withdraw.dart';
import 'package:reloc/views/home/payment/deposit.dart';
import 'package:reloc/views/home/payment/wallet.dart';
import 'package:reloc/views/admin/admin_mover_screen.dart';
import 'package:reloc/views/admin/approve_mover_screen.dart';

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
            final role = data['role'] ?? 'user';
            final about = data['about'] ?? '';
            final occupation = data['occupation'] ?? '';
            final company = data['company'] ?? '';
            final address = data['address'] ?? '';
            final city = data['city'] ?? '';
            final state = data['state'] ?? '';
            final country = data['country'] ?? '';
            final movingType = data['movingType'] ?? 'Not specified';
            final timeline = data['timeline'] ?? 'Not specified';
            final preferredMoverType = data['preferredMoverType'] ?? 'Not specified';

            return CustomScrollView(
              slivers: [
                // Compact App Bar
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryVariant],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    ),
                  ],
                ),
                
                // Compact Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // ✅ Compact Profile Header
                        _buildCompactProfileHeader(name, email, photo, role),
                        const SizedBox(height: 16),

                        // ✅ Admin Section (Only for Admin users)
                        if (role.toLowerCase() == 'admin') ...[
                          _buildAdminSection(),
                          const SizedBox(height: 16),
                        ],

                        // ✅ Profile Completion Card (Compact)
                        _buildCompactProfileCompletionCard(data),
                        const SizedBox(height: 16),

                        // ✅ Information Sections in Compact Grid
                        _buildCompactInfoSections(
                          name, about, occupation, company, 
                          address, city, state, country, 
                          movingType, timeline, preferredMoverType
                        ),
                        const SizedBox(height: 16),

                        // ✅ Combined Options & Wallet Section
                        _buildCombinedActionsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Header
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Admin Buttons
          Row(
            children: [
              Expanded(
                child: _buildAdminButton(
                  'Approve Movers',
                  Icons.verified_user_outlined,
                  Colors.green,
                  () {
                    // Navigate to approve movers screen
                    _navigateToApproveMovers();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAdminButton(
                  'Manage Movers',
                  Icons.delete_outline,
                  Colors.red,
                  () {
                    // Navigate to remove movers screen
                    _navigateToRemoveMovers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 16, color: Colors.white),
        onPressed: onTap,
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateToApproveMovers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ApproveMoverScreen()));
  }

  void _navigateToRemoveMovers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMoverScreen()));
  }

  Widget _buildCompactProfileHeader(String name, String email, String? photo, String role) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: photo != null && photo.isNotEmpty
                ? ClipOval(child: Image.network(photo, fit: BoxFit.cover))
                : const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getRoleDisplay(role),
                    style: TextStyle(color: _getRoleColor(role), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProfileCompletionCard(Map<String, dynamic> data) {
    final completedFields = _calculateProfileCompletion(data);
    final completionPercentage = (completedFields / 15) * 100;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF00C853), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Completion', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$completedFields/15 fields', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Text('${completionPercentage.toInt()}%', 
                style: TextStyle(color: _getCompletionColor(completionPercentage), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: AppColors.textPrimary.withOpacity(0.24),
            valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(completionPercentage)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
              child: const Text('Complete Profile', style: TextStyle(color: Color(0xFF00C853), fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompactInfoSections(
    String name, String about, String occupation, String company,
    String address, String city, String state, String country,
    String movingType, String timeline, String preferredMoverType
  ) {
    return Column(
      children: [
        // Personal & Address Info in Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Info
            Expanded(
              child: _buildCompactInfoSection(
                'Personal Info',
                Icons.person_outline,
                [
                  _buildCompactInfoRow('Name', name),
                  if (about.isNotEmpty) _buildCompactInfoRow('About', about),
                  if (occupation.isNotEmpty) _buildCompactInfoRow('Occupation', occupation),
                  if (company.isNotEmpty) _buildCompactInfoRow('Company', company),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Address Info
            if (address.isNotEmpty || city.isNotEmpty || state.isNotEmpty || country.isNotEmpty)
            Expanded(
              child: _buildCompactInfoSection(
                'Address',
                Icons.location_on_outlined,
                [
                  if (address.isNotEmpty) _buildCompactInfoRow('Address', address),
                  if (city.isNotEmpty) _buildCompactInfoRow('City', city),
                  if (state.isNotEmpty) _buildCompactInfoRow('State', state),
                  if (country.isNotEmpty) _buildCompactInfoRow('Country', country),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Moving Preferences
        _buildCompactInfoSection(
          'Moving Preferences',
          Icons.move_to_inbox_outlined,
          [
            _buildCompactInfoRow('Type', _getMovingTypeDisplay(movingType)),
            _buildCompactInfoRow('Timeline', _getTimelineDisplay(timeline)),
            _buildCompactInfoRow('Mover Type', _getMoverTypeDisplay(preferredMoverType)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ),
          Expanded(
            child: Text(value, 
              style: const TextStyle(color: Colors.white, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedActionsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          // Profile Options
          _buildCompactOptionTile(Icons.edit_note, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),
          _buildCompactOptionTile(Icons.bookmark_outline, 'Saved Posts', () {
            Navigator.pushNamed(context, AppRoutes.savedPosts);
          }),
          _buildCompactOptionTile(Icons.settings, 'Settings', () {
            Navigator.pushNamed(context, AppRoutes.settings);
          }),

          const Divider(color: Colors.white24, height: 16),

          // Wallet Actions
          const Text('Wallet & Payments', 
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(child: _buildCompactPaymentButton('Wallet', Icons.account_balance_wallet_outlined, Colors.teal, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())))),
              const SizedBox(width: 6),
              Expanded(child: _buildCompactPaymentButton('Deposit', Icons.arrow_downward, AppColors.primary, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen())))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildCompactPaymentButton('Pay', Icons.send, AppColors.primary, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())))),
              const SizedBox(width: 6),
              Expanded(child: _buildCompactPaymentButton('Withdraw', Icons.arrow_upward, Colors.orange, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())))),
            ],
          ),

          const Divider(color: Colors.white24, height: 16),

          // Logout
          _buildCompactOptionTile(Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCompactOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary, size: 16),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white54),
      onTap: onTap,
    );
  }

  Widget _buildCompactPaymentButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 14, color: Colors.white),
        onPressed: onTap,
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Helper methods (unchanged)
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'mover': return AppColors.primary;
      case 'admin': return const Color(0xFFFF9800);
      default: return const Color(0xFF2196F3);
    }
  }

  String _getRoleDisplay(String role) {
    switch (role.toLowerCase()) {
      case 'mover': return 'Verified Mover';
      case 'admin': return 'Administrator';
      default: return 'Resident';
    }
  }

  String _getMovingTypeDisplay(String movingType) {
    switch (movingType) {
      case 'residential': return 'Residential';
      case 'commercial': return 'Commercial';
      case 'both': return 'Both';
      default: return 'Not specified';
    }
  }

  String _getTimelineDisplay(String timeline) {
    switch (timeline) {
      case 'urgent': return 'Urgent (Within 1 week)';
      case 'flexible': return 'Flexible (1-4 weeks)';
      case 'specific_date': return 'Specific Date';
      default: return 'Not specified';
    }
  }

  String _getMoverTypeDisplay(String moverType) {
    switch (moverType) {
      case 'individual': return 'Individual Mover';
      case 'company': return 'Moving Company';
      case 'any': return 'Any Type';
      default: return 'Not specified';
    }
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return AppColors.primary;
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  int _calculateProfileCompletion(Map<String, dynamic> data) {
    int completed = 0;
    final fields = [
      'name', 'email', 'phone', 'about', 'occupation', 'company',
      'address', 'city', 'state', 'country', 'movingType', 'timeline',
      'preferredMoverType', 'emergencyContact', 'emergencyPhone'
    ];
    
    for (final field in fields) {
      if (data[field] != null && data[field].toString().isNotEmpty) completed++;
    }
    
    return completed;
  }
}