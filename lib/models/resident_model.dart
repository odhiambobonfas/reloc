import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ResidentModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? location;
  final String? description;
  final DateTime? movingDate;
  final double? budget;
  final String status; // e.g. 'available', 'matched', 'completed'
  final double? rating;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String fromLocation;
  final String toLocation;

  ResidentModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.location,
    this.description,
    this.movingDate,
    this.budget,
    this.status = 'available',
    this.rating,
    this.createdAt,
    this.updatedAt,
    required this.fromLocation,
    required this.toLocation,
  });
  factory ResidentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ResidentModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      location: data['location'],
      description: data['description'],
      movingDate: data['movingDate'] != null
          ? (data['movingDate'] as Timestamp).toDate()
          : null,
      budget: (data['budget'] is int)
          ? (data['budget'] as int).toDouble()
          : data['budget']?.toDouble(),
      status: data['status'] ?? 'available',
      rating: data['rating']?.toDouble(),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      fromLocation: data['fromLocation'] ?? '',
      toLocation: data['toLocation'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'location': location,
      'description': description,
      'movingDate': movingDate != null ? Timestamp.fromDate(movingDate!) : null,
      'budget': budget,
      'status': status,
      'rating': rating,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
    };
  }

  ResidentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? location,
    String? description,
    DateTime? movingDate,
    double? budget,
    String? status,
    double? rating,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? fromLocation,
    String? toLocation,
  }) {
    return ResidentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      description: description ?? this.description,
      movingDate: movingDate ?? this.movingDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
    );
  }
  // Add this static method to create a ResidentModel from a map and id
  static ResidentModel fromMap(Map<String, dynamic> map, String id) {
    return ResidentModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      location: map['location'],
      description: map['description'],
      movingDate: map['movingDate'] != null
          ? (map['movingDate'] as Timestamp).toDate()
          : null,
      budget: (map['budget'] is int)
          ? (map['budget'] as int).toDouble()
          : map['budget']?.toDouble(),
      status: map['status'] ?? 'available',
      rating: map['rating']?.toDouble(),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
    );
  }
}

      // Define uid before using it, for example:
      final String uid = 'some_unique_id'; // Replace with actual UID source

      // Define the controllers before using them
      final _nameController = TextEditingController();
      final _emailController = TextEditingController();
      final _phoneController = TextEditingController();

      final resident = ResidentModel(
        id: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: '',
        fromLocation: '', // Provide appropriate value or leave empty if unknown
        toLocation: '',   // Provide appropriate value or leave empty if unknown
      );