import 'package:cloud_firestore/cloud_firestore.dart';



class MoverModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? serviceArea;
  final String? description;
  final double? rate;
  final String status; // e.g., 'available', 'unavailable'
  final double? rating;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  MoverModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.serviceArea,
    this.description,
    this.rate,
    this.status = 'available',
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to create MoverModel from Firestore document
  factory MoverModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MoverModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      serviceArea: data['serviceArea'],
      description: data['description'],
      rate: (data['rate'] is int) ? (data['rate'] as int).toDouble() : data['rate']?.toDouble(),
      status: data['status'] ?? 'available',
      rating: data['rating']?.toDouble(),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  /// Converts model to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'serviceArea': serviceArea,
      'description': description,
      'rate': rate,
      'status': status,
      'rating': rating,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Clone with new values
  MoverModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? serviceArea,
    String? description,
    double? rate,
    String? status,
    double? rating,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return MoverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      serviceArea: serviceArea ?? this.serviceArea,
      description: description ?? this.description,
      rate: rate ?? this.rate,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

