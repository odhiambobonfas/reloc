import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _servicesController = TextEditingController();
  final _aboutController = TextEditingController();
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  bool _isLoading = false;
  String? _currentRole;
  String _selectedMovingType = 'residential';
  String _selectedTimeline = 'flexible';
  String _selectedPreferredMoverType = 'any';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _currentRole == 'mover' ? 4 : 5, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _currentRole = data['role'] ?? 'resident';
        _aboutController.text = data['about'] ?? '';
        _occupationController.text = data['occupation'] ?? '';
        _companyController.text = data['company'] ?? '';
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
        _stateController.text = data['state'] ?? '';
        _countryController.text = data['country'] ?? '';
        _postalCodeController.text = data['postalCode'] ?? '';
        _emergencyContactController.text = data['emergencyContact'] ?? '';
        _emergencyPhoneController.text = data['emergencyPhone'] ?? '';
        
        setState(() {
          _tabController = TabController(length: _currentRole == 'mover' ? 4 : 5, vsync: this);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'about': _aboutController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'company': _companyController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'movingType': _selectedMovingType,
        'timeline': _selectedTimeline,
        'preferredMoverType': _selectedPreferredMoverType,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _requestMoverRole() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    await _firestore.collection('roleRequests').doc(user.uid).set({
      'uid': user.uid,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'idNumber': _idNumberController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'location': _locationController.text.trim(),
      'services': _servicesController.text.trim(),
      'requestedRole': 'mover',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mover request sent to admin')),
    );
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
            
            // Tab Navigation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF00C853),
                labelColor: const Color(0xFF00C853),
                unselectedLabelColor: Colors.white60,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  const Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Basic'),
                  const Tab(icon: Icon(Icons.location_on_outlined, size: 20), text: 'Address'),
                  const Tab(icon: Icon(Icons.move_to_inbox_outlined, size: 20), text: 'Preferences'),
                  const Tab(icon: Icon(Icons.emergency_outlined, size: 20), text: 'Emergency'),
                  if (_currentRole != 'mover')
                    const Tab(icon: Icon(Icons.work_outline, size: 20), text: 'Become Mover'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildAddressTab(),
                    _buildPreferencesTab(),
                    _buildEmergencyTab(),
                    if (_currentRole != 'mover') _buildMoverRequestTab(),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            _buildActionButtons(),
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
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompactTextField(
            controller: _aboutController,
            label: 'About Me',
            icon: Icons.info_outline,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCompactTextField(
                  controller: _occupationController,
                  label: 'Occupation',
                  icon: Icons.work_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTextField(
                  controller: _companyController,
                  label: 'Company',
                  icon: Icons.business_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompactTextField(
            controller: _addressController,
            label: 'Street Address',
            icon: Icons.home_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCompactTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCompactTextField(
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.public_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  icon: Icons.markunread_mailbox_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompactDropdown(
            label: 'Moving Type',
            value: _selectedMovingType,
            items: const [
              DropdownMenuItem(value: 'residential', child: Text('Residential')),
              DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
              DropdownMenuItem(value: 'both', child: Text('Both')),
            ],
            onChanged: (value) => setState(() => _selectedMovingType = value!),
          ),
          const SizedBox(height: 16),
          _buildCompactDropdown(
            label: 'Timeline',
            value: _selectedTimeline,
            items: const [
              DropdownMenuItem(value: 'urgent', child: Text('Urgent (Within 1 week)')),
              DropdownMenuItem(value: 'flexible', child: Text('Flexible (1-4 weeks)')),
              DropdownMenuItem(value: 'specific_date', child: Text('Specific Date')),
            ],
            onChanged: (value) => setState(() => _selectedTimeline = value!),
          ),
          const SizedBox(height: 16),
          _buildCompactDropdown(
            label: 'Preferred Mover Type',
            value: _selectedPreferredMoverType,
            items: const [
              DropdownMenuItem(value: 'individual', child: Text('Individual Mover')),
              DropdownMenuItem(value: 'company', child: Text('Moving Company')),
              DropdownMenuItem(value: 'any', child: Text('Any Type')),
            ],
            onChanged: (value) => setState(() => _selectedPreferredMoverType = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompactTextField(
            controller: _emergencyContactController,
            label: 'Emergency Contact Name',
            icon: Icons.person_add_outlined,
          ),
          const SizedBox(height: 16),
          _buildCompactTextField(
            controller: _emergencyPhoneController,
            label: 'Emergency Contact Phone',
            icon: Icons.phone_in_talk_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildMoverRequestTab() {
    return _currentRole == 'mover' 
        ? _buildMoverStatusCard()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCompactTextField(
                  controller: _idNumberController,
                  label: 'ID/Passport Number',
                  icon: Icons.badge_outlined,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildCompactTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  icon: Icons.business_outlined,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildCompactTextField(
                  controller: _locationController,
                  label: 'Business Location',
                  icon: Icons.location_on_outlined,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildCompactTextField(
                  controller: _servicesController,
                  label: 'Services Offered',
                  icon: Icons.list_alt_outlined,
                  maxLines: 2,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildCompactDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
      dropdownColor: const Color(0xFF1A1A1A),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentRole != 'mover' && _tabController.index == 4) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestMoverRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('REQUEST MOVER ROLE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('SAVE PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoverStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "✅ Verified Mover",
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You are already a verified mover in our system",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}