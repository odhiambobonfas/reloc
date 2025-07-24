import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mover_model.dart';

class MoverProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MoverModel? _mover;
  bool _isLoading = false;
  String? _error;

  MoverModel? get mover => _mover;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch the logged-in mover's profile data from Firestore
  Future<void> fetchMoverProfile() async {
    _setLoading(true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final doc = await _firestore.collection('movers').doc(uid).get();

      if (doc.exists) {
        _mover = MoverModel.fromDocument(doc);
      }

      _setLoading(false);
    } catch (e) {
      _setError("Failed to fetch mover: $e");
    }
  }

  /// Post or update the mover's availability information
  Future<void> postAvailability(MoverModel moverData) async {
    _setLoading(true);
    try {
      await _firestore.collection('movers').doc(moverData.id).set(
            moverData.toMap(),
            SetOptions(merge: true),
          );

      _mover = moverData;
      _setLoading(false);
    } catch (e) {
      _setError("Failed to post availability: $e");
    }
  }

  /// Retrieve all movers with status 'available' (for residents or admin view)
  Future<List<MoverModel>> fetchAvailableMovers() async {
    try {
      final snapshot = await _firestore
          .collection('movers')
          .where('status', isEqualTo: 'available')
          .get();

      return snapshot.docs
          .map((doc) => MoverModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _setError("Error loading available movers: $e");
      return [];
    }
  }

  /// Update mover profile (e.g., area, description, rate)
  Future<void> updateMoverProfile(Map<String, dynamic> updatedData) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      await _firestore.collection('movers').doc(uid).update(updatedData);
      await fetchMoverProfile(); // Refresh the local state
    } catch (e) {
      _setError("Failed to update mover profile: $e");
    }
  }

  /// Clear the mover state (used during logout)
  void clear() {
    _mover = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
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
}
