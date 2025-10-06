import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMoverScreen extends StatefulWidget {
  const AdminMoverScreen({super.key});
  
  @override
  State<AdminMoverScreen> createState() => _AdminMoverScreenState();
}

class _AdminMoverScreenState extends State<AdminMoverScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  String _searchQuery = '';
  List<Map<String, dynamic>> _allMovers = [];
  List<Map<String, dynamic>> _filteredMovers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMovers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilter();
    });
  }

  Future<void> _loadMovers() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'mover')
          .orderBy('approvedAt', descending: true)
          .get();
      
      _allMovers = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      _applyFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading movers: $e')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredMovers = List.from(_allMovers);
    } else {
      _filteredMovers = _allMovers.where((mover) {
        final name = (mover['name'] ?? '').toLowerCase();
        final businessName = (mover['businessName'] ?? '').toLowerCase();
        final phone = (mover['phone'] ?? '').toLowerCase();
        final location = (mover['businessLocation'] ?? '').toLowerCase();
        
        return name.contains(_searchQuery) ||
               businessName.contains(_searchQuery) ||
               phone.contains(_searchQuery) ||
               location.contains(_searchQuery);
      }).toList();
    }
    setState(() {});
  }

  Future<void> _showMoverDetails(Map<String, dynamic> mover) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMoverDetailsModal(mover),
    );
  }

  Future<void> _confirmRemoveMover(Map<String, dynamic> mover) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(mover),
    );

    if (confirmed == true) {
      await _removeMover(mover);
    }
  }

  Future<void> _removeMover(Map<String, dynamic> mover) async {
    setState(() => _isLoading = true);
    
    try {
      final batch = _firestore.batch();
      
      // Update user role back to resident
      final userRef = _firestore.collection('users').doc(mover['id']);
      batch.update(userRef, {
        'role': 'resident',
        'businessName': FieldValue.delete(),
        'businessLocation': FieldValue.delete(),
        'services': FieldValue.delete(),
        'idNumber': FieldValue.delete(),
        'approvedAt': FieldValue.delete(),
        'removedFromMoverAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Add removal log
      final logRef = _firestore.collection('adminLogs').doc();
      batch.set(logRef, {
        'action': 'mover_removed',
        'targetUserId': mover['id'],
        'targetUserName': mover['name'],
        'targetBusinessName': mover['businessName'],
        'adminId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'reason': 'Admin removal',
      });
      
      // Update any pending role requests
      final roleRequestRef = _firestore.collection('roleRequests').doc(mover['id']);
      batch.update(roleRequestRef, {
        'status': 'revoked',
        'revokedAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      
      // Reload data
      await _loadMovers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mover['name']} removed from movers successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing mover: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _suspendMover(Map<String, dynamic> mover) async {
    setState(() => _isLoading = true);
    
    try {
      await _firestore.collection('users').doc(mover['id']).update({
        'role': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Add suspension log
      await _firestore.collection('adminLogs').add({
        'action': 'mover_suspended',
        'targetUserId': mover['id'],
        'targetUserName': mover['name'],
        'adminId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _loadMovers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mover['name']} suspended successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error suspending mover: $e')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            _buildHeader(),
            
            // Search and Stats Bar
            _buildSearchBar(),
            
            // Tab Navigation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00C853),
                labelColor: const Color(0xFF00C853),
                unselectedLabelColor: Colors.white60,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text('All (${_filteredMovers.length})'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics, size: 16),
                        SizedBox(width: 4),
                        Text('Analytics'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading 
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMoversList(_filteredMovers),
                        _buildAnalyticsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00E676)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Manage Movers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMovers,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.manage_accounts,
                  color: Color(0xFF00C853),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mover Management Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Total Movers: ${_allMovers.length} | Showing: ${_filteredMovers.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name, business, phone, or location...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00C853)),
              filled: true,
              fillColor: const Color(0xFF0F0F0F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00C853), width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoversList(List<Map<String, dynamic>> movers) {
    if (movers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No movers found' : 'No movers match your search',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movers.length,
      itemBuilder: (context, index) {
        final mover = movers[index];
        return _buildMoverCard(mover);
      },
    );
  }

  Widget _buildMoverCard(Map<String, dynamic> mover) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _showMoverDetails(mover),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Profile Avatar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF00C853),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Mover Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mover['name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mover['businessName'] ?? 'No business name',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                mover['businessLocation'] ?? 'No location',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMoverDetails(mover),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00C853),
                        side: const BorderSide(color: Color(0xFF00C853)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('VIEW DETAILS'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _suspendMover(mover),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.pause_circle, size: 16),
                      label: const Text('SUSPEND'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmRemoveMover(mover),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever, size: 16),
                      label: const Text('REMOVE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoverDetailsModal(Map<String, dynamic> mover) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mover Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Modal Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  _buildDetailSection('Personal Information', [
                    _buildDetailRow('Full Name', mover['name'] ?? 'N/A'),
                    _buildDetailRow('Phone Number', mover['phone'] ?? 'N/A'),
                    _buildDetailRow('Email', mover['email'] ?? 'N/A'),
                    _buildDetailRow('ID Number', mover['idNumber'] ?? 'N/A'),
                    _buildDetailRow('About', mover['about'] ?? 'No description'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Business Information
                  _buildDetailSection('Business Information', [
                    _buildDetailRow('Business Name', mover['businessName'] ?? 'N/A'),
                    _buildDetailRow('Location', mover['businessLocation'] ?? 'N/A'),
                    _buildDetailRow('Services Offered', mover['services'] ?? 'N/A'),
                    _buildDetailRow('Occupation', mover['occupation'] ?? 'N/A'),
                    _buildDetailRow('Company', mover['company'] ?? 'N/A'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Address Information
                  _buildDetailSection('Address Information', [
                    _buildDetailRow('Street Address', mover['address'] ?? 'N/A'),
                    _buildDetailRow('City', mover['city'] ?? 'N/A'),
                    _buildDetailRow('State/Province', mover['state'] ?? 'N/A'),
                    _buildDetailRow('Country', mover['country'] ?? 'N/A'),
                    _buildDetailRow('Postal Code', mover['postalCode'] ?? 'N/A'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Emergency Contact
                  _buildDetailSection('Emergency Contact', [
                    _buildDetailRow('Contact Name', mover['emergencyContact'] ?? 'N/A'),
                    _buildDetailRow('Contact Phone', mover['emergencyPhone'] ?? 'N/A'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // System Information
                  _buildDetailSection('System Information', [
                    _buildDetailRow('User ID', mover['id'] ?? 'N/A'),
                    _buildDetailRow('Role', mover['role'] ?? 'N/A'),
                    _buildDetailRow('Approved Date', _formatTimestamp(mover['approvedAt'])),
                    _buildDetailRow('Last Updated', _formatTimestamp(mover['updatedAt'])),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDialog(Map<String, dynamic> mover) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 24),
          SizedBox(width: 8),
          Text('Confirm Removal', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to remove ${mover['name']} as a mover?',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'This action will:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Remove mover privileges\n• Convert back to regular resident\n• Remove business information\n• Log the action for audit',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('REMOVE MOVER'),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Movers', '${_allMovers.length}', Icons.people, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('This Month', '0', Icons.trending_up, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Suspended', '0', Icons.pause_circle, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Removed', '0', Icons.delete, Colors.red),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'No recent activity to display',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00C853),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: details),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      final date = timestamp is Timestamp 
          ? timestamp.toDate() 
          : DateTime.parse(timestamp.toString());
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}