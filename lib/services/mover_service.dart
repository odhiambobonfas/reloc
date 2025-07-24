import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Post mover availability
  Future<void> postAvailability(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _firestore.collection('movers').doc(user.uid).set({
      ...data,
      'userId': user.uid,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetch all available movers (for admin or residents to browse)
  Stream<QuerySnapshot> getAvailableMovers() {
    return _firestore
        .collection('movers')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get single mover profile by userId
  Future<DocumentSnapshot> getMoverById(String uid) {
    return _firestore.collection('movers').doc(uid).get();
  }

  /// Update mover profile
  Future<void> updateMoverProfile(String uid, Map<String, dynamic> updatedData) async {
    await _firestore.collection('movers').doc(uid).update({
      ...updatedData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete mover listing (e.g. by admin or mover)
  Future<void> deleteMover(String uid) async {
    await _firestore.collection('movers').doc(uid).delete();
  }

  /// Get current mover data for profile
  Future<DocumentSnapshot?> getCurrentMoverData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('movers').doc(user.uid).get();
  }
}
