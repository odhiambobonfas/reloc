import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reloc/core/constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Mover Fields
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _serviceAreaController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _paymentPhoneController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _yearsOfOperationController = TextEditingController();

  // Resident Fields
  final TextEditingController _housingTypeController = TextEditingController();
  final TextEditingController _familySizeController = TextEditingController();
  final TextEditingController _moveDateController = TextEditingController();
  final TextEditingController _currentLandlordController = TextEditingController();
  final TextEditingController _leaseDurationController = TextEditingController();

  String? _role;
  bool _isRoleEditable = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data();
    if (data == null) return;

    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _locationController.text = data['location'] ?? '';
    _bioController.text = data['bio'] ?? '';

    final fetchedRole = data['role'];
    if (fetchedRole == 'mover' || fetchedRole == 'resident') {
      _role = fetchedRole;
      _isRoleEditable = false;
    }

    if (_role == 'mover') {
      _nationalIdController.text = data['nationalId'] ?? '';
      _serviceAreaController.text = data['serviceArea'] ?? '';
      _rateController.text = data['rate']?.toString() ?? '';
      _vehicleTypeController.text = data['vehicleType'] ?? '';
      _experienceController.text = data['experience'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _availabilityController.text = data['availability'] ?? '';
      _paymentPhoneController.text = data['paymentPhone'] ?? '';
      _licenseNumberController.text = data['licenseNumber'] ?? '';
      _yearsOfOperationController.text = data['yearsOfOperation']?.toString() ?? '';
    } else if (_role == 'resident') {
      _housingTypeController.text = data['housingType'] ?? '';
      _familySizeController.text = data['familySize'] ?? '';
      _moveDateController.text = data['preferredMoveDate'] ?? '';
      _currentLandlordController.text = data['currentLandlord'] ?? '';
      _leaseDurationController.text = data['leaseDuration'] ?? '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null || _role == null) return;

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'bio': _bioController.text.trim(),
      'role': _role,
    };

    if (_role == 'mover') {
      data.addAll({
        'nationalId': _nationalIdController.text.trim(),
        'serviceArea': _serviceAreaController.text.trim(),
        'rate': (int.tryParse(_rateController.text.trim()) ?? 0).toString(),
        'vehicleType': _vehicleTypeController.text.trim(),
        'experience': _experienceController.text.trim(),
        'description': _descriptionController.text.trim(),
        'availability': _availabilityController.text.trim(),
        'paymentPhone': _paymentPhoneController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'yearsOfOperation': (int.tryParse(_yearsOfOperationController.text.trim()) ?? 0).toString(),
      });
    } else if (_role == 'resident') {
      data.addAll({
        'housingType': _housingTypeController.text.trim(),
        'familySize': _familySizeController.text.trim(),
        'preferredMoveDate': _moveDateController.text.trim(),
        'currentLandlord': _currentLandlordController.text.trim(),
        'leaseDuration': _leaseDurationController.text.trim(),
      });
    }

    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildDropdownRoleSelector() {
    return _isRoleEditable
        ? DropdownButtonFormField<String>(
            value: _role,
            dropdownColor: AppColors.navBar,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Select Role'),
            items: const [
              DropdownMenuItem(value: 'mover', child: Text('Mover')),
              DropdownMenuItem(value: 'resident', child: Text('Resident')),
            ],
            onChanged: (value) {
              setState(() => _role = value);
            },
            validator: (value) => value == null ? 'Please select a role' : null,
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              initialValue: _role?.toUpperCase(),
              readOnly: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: _inputDecoration('Role'),
            ),
          );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.navBar,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: _inputDecoration(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.navBar,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDropdownRoleSelector(),
                    _buildTextField(_nameController, 'Full Name'),
                    _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
                    _buildTextField(_locationController, 'Location'),
                    _buildTextField(_bioController, 'Bio', maxLines: 3),

                    if (_role == 'mover') ...[
                      _buildTextField(_nationalIdController, 'National ID'),
                      _buildTextField(_serviceAreaController, 'Service Area'),
                      _buildTextField(_rateController, 'Rate per Hour (KES)', keyboardType: TextInputType.number),
                      _buildTextField(_vehicleTypeController, 'Vehicle Type'),
                      _buildTextField(_experienceController, 'Experience Level'),
                      _buildTextField(_descriptionController, 'Description'),
                      _buildTextField(_availabilityController, 'Availability Status'),
                      _buildTextField(_paymentPhoneController, 'Payment Phone'),
                      _buildTextField(_licenseNumberController, 'License Number'),
                      _buildTextField(_yearsOfOperationController, 'Years of Operation', keyboardType: TextInputType.number),
                    ],

                    if (_role == 'resident') ...[
                      _buildTextField(_housingTypeController, 'Housing Type'),
                      _buildTextField(_familySizeController, 'Family Size'),
                      _buildTextField(_moveDateController, 'Preferred Move Date'),
                      _buildTextField(_currentLandlordController, 'Current Landlord'),
                      _buildTextField(_leaseDurationController, 'Lease Duration'),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveProfile,
                      child: const Text('Save Changes', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
