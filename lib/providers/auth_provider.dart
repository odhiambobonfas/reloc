import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Removed duplicate AuthProvider class to resolve naming conflict.

// Define UserModel if not already defined elsewhere
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String photoUrl;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.isVerified,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    // TODO: Implement Google sign-in logic here
    // For example, use google_sign_in package or Firebase Auth
    // throw UnimplementedError();
  }
  
   Future<void> signInWithApple() async {
    // TODO: Implement Apple Sign-In logic here
    // For now, just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
    // Throw UnimplementedError if not yet implemented
    // throw UnimplementedError('Apple Sign-In not implemented');
  }

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Automatically called on app start (if user is already logged in)
  Future<void> initializeUser() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      await _fetchUserData(_firebaseUser!.uid);
    }
    notifyListeners();
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _setLoading(true);

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email,
        name: name,
        role: role,
        photoUrl: '',
        isVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());

      _firebaseUser = cred.user;
      _userModel = user;

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Registration failed');
      return false;
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = cred.user;
      await _fetchUserData(_firebaseUser!.uid);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Login failed');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }

  /// Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      _userModel = UserModel.fromDocument(doc);
    } else {
      _userModel = null;
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

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
