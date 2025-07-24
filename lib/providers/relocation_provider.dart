import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RelocationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Send a relocation request from a resident to a mover
  Future<void> sendRelocationRequest({
    required String moverId,
    required String details,
  }) async {
    _setLoading(true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      final relocationData = {
        'residentId': user.uid,
        'moverId': moverId,
        'details': details,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('relocations').add(relocationData);
      _setLoading(false);
    } catch (e) {
      _setError("Failed to send request: $e");
    }
  }

  /// Mover accepts a relocation request
  Future<void> acceptRequest(String requestId) async {
    await _updateRequestStatus(requestId, 'accepted');
  }

  /// Mover rejects a relocation request
  Future<void> rejectRequest(String requestId) async {
    await _updateRequestStatus(requestId, 'rejected');
  }

  /// Complete a relocation (done by mover)
  Future<void> completeRequest(String requestId) async {
    await _updateRequestStatus(requestId, 'completed');
  }

  /// Get all relocation requests for the current user (resident or mover)
  Future<List<Map<String, dynamic>>> getMyRelocations() async {
    _setLoading(true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Not logged in");

      final snapshot = await _firestore
          .collection('relocations')
          .where(
            Filter.or(
              Filter('residentId', isEqualTo: user.uid),
              Filter('moverId', isEqualTo: user.uid),
            ),
          )
          .orderBy('timestamp', descending: true)
          .get();

      final relocations = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _setLoading(false);
      return relocations;
    } catch (e) {
      _setError("Failed to fetch relocations: $e");
      return [];
    }
  }

  /// Internal: update status field of a relocation request
  Future<void> _updateRequestStatus(String requestId, String status) async {
    _setLoading(true);
    try {
      await _firestore.collection('relocations').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _setLoading(false);
    } catch (e) {
      _setError("Error updating request: $e");
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error and reset state (optional)
  void clear() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
