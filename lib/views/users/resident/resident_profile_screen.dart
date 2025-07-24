import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resident Profile'),
        backgroundColor: AppColors.navBar,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  _buildInfoCard('Personal Information', [
                    _buildInfoItem('Full Name', _userData?['name']),
                    _buildInfoItem('Email', _userData?['email']),
                    _buildInfoItem('Phone', _userData?['phone']),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoCard('Moving Details', [
                    _buildInfoItem('Current Address', _userData?['address']),
                    _buildInfoItem('House Size', _userData?['houseSize']),
                    _buildInfoItem('Planned Move Date', _userData?['moveDate']),
                    _buildInfoItem('Family Size', _userData?['familySize']),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoCard('Other Information', [
                    _buildInfoItem('Payment Phone', _userData?['paymentPhone']),
                    _buildInfoItem('Special Needs', _userData?['specialNeeds']),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.navBar,
          backgroundImage: _auth.currentUser?.photoURL != null
              ? NetworkImage(_auth.currentUser!.photoURL!)
              : null,
          child: _auth.currentUser?.photoURL == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          _userData?['name'] ?? 'Resident',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (_userData?['address'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _userData!['address']!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> items) {
    return Card(
      color: AppColors.navBar,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not specified',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}