import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in");

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    } else {
      // Fallback to Firebase Auth default details
      return {
        "name": user.displayName ?? "Not Set",
        "email": user.email ?? "Not Set",
        "phone": user.phoneNumber ?? "Not Set",
        "role": "User", // default role
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Account"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No account details found"));
          }

          final userData = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text("Name"),
                subtitle: Text(userData["name"] ?? "Not Set"),
              ),
              ListTile(
                title: const Text("Email"),
                subtitle: Text(userData["email"] ?? "Not Set"),
              ),
              ListTile(
                title: const Text("Phone"),
                subtitle: Text(userData["phone"] ?? "Not Set"),
              ),
              ListTile(
                title: const Text("Role"),
                subtitle: Text(userData["role"] ?? "User"),
              ),
            ],
          );
        },
      ),
    );
  }
}
