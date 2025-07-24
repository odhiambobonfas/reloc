import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all users from Firestore
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('users').get();
      _allUsers = snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();

      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load users: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Filter users by role (e.g., mover, resident)
  List<UserModel> filterByRole(String role) {
    return _allUsers.where((user) => user.role == role).toList();
  }

  /// Delete a user by ID
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _allUsers.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting user: $e';
      notifyListeners();
    }
  }

  /// Mark user as verified
  Future<void> verifyUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      int index = _allUsers.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(isVerified: true);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error verifying user: $e';
      notifyListeners();
    }
  }

  /// Detect duplicate users by email (same email used more than once)
  List<UserModel> findDuplicateEmails() {
    final Map<String, List<UserModel>> grouped = {};

    for (var user in _allUsers) {
      grouped.putIfAbsent(user.email, () => []).add(user);
    }

    return grouped.values
        .where((list) => list.length > 1)
        .expand((list) => list)
        .toList();
  }

  /// Reset state (optional if you want to refresh)
  void clear() {
    _allUsers = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
