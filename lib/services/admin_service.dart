import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
  }

  /// Delete user by ID
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Filter out duplicate users based on email
  Future<List<Map<String, dynamic>>> findDuplicateUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs.map((doc) => doc.data()).toList();

    final Map<String, List<Map<String, dynamic>>> emailGroups = {};

    for (var user in users) {
      final email = user['email'];
      if (emailGroups.containsKey(email)) {
        emailGroups[email]!.add(user);
      } else {
        emailGroups[email] = [user];
      }
    }

    // Return duplicates only
    return emailGroups.entries
        .where((entry) => entry.value.length > 1)
        .expand((entry) => entry.value)
        .toList();
  }

  /// Change user role (e.g., from mover to resident)
  Future<void> updateUserRole(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole,
    });
  }

  /// Generate basic user count report
  Future<Map<String, int>> getUserCountsByRole() async {
    final snapshot = await _firestore.collection('users').get();
    final docs = snapshot.docs;

    int movers = 0;
    int residents = 0;
    int admins = 0;

    for (var doc in docs) {
      final role = doc.data()['role'];
      if (role == 'mover') movers++;
      if (role == 'resident') residents++;
      if (role == 'admin') admins++;
    }

    return {
      'movers': movers,
      'residents': residents,
      'admins': admins,
    };
  }
}
