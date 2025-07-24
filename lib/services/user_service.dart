import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's Firestore document
  Future<DocumentSnapshot> getCurrentUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user is currently logged in");
    return _firestore.collection('users').doc(user.uid).get();
  }

  /// Get user document by ID
  Future<DocumentSnapshot> getUserById(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Update current user's profile
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user is currently logged in");

    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }

  /// Get list of all users (for admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
  }

  /// Delete a user (admin only)
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'admin';
  }

  /// Check if user is mover
  Future<bool> isMover(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'mover';
  }

  /// Check if user is resident
  Future<bool> isResident(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'resident';
  }
}
