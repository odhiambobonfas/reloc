import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  // Enhanced fields
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? about;
  final String? occupation;
  final String? company;
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String>? preferences;
  final String? movingType; // 'residential', 'commercial', 'both'
  final int? numberOfRooms;
  final bool? hasFurniture;
  final bool? needsPacking;
  final bool? needsStorage;
  final String? specialRequirements;
  final String? preferredMoverType; // 'individual', 'company', 'any'
  final double? maxBudget;
  final String? timeline; // 'urgent', 'flexible', 'specific_date'
  final bool? isVerified;
  final String? verificationStatus; // 'pending', 'verified', 'rejected'
  final String? idDocumentUrl;
  final String? proofOfAddressUrl;

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
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.about,
    this.occupation,
    this.company,
    this.emergencyContact,
    this.emergencyPhone,
    this.preferences,
    this.movingType,
    this.numberOfRooms,
    this.hasFurniture,
    this.needsPacking,
    this.needsStorage,
    this.specialRequirements,
    this.preferredMoverType,
    this.maxBudget,
    this.timeline,
    this.isVerified,
    this.verificationStatus,
    this.idDocumentUrl,
    this.proofOfAddressUrl,
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
      address: data['address'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      postalCode: data['postalCode'],
      about: data['about'],
      occupation: data['occupation'],
      company: data['company'],
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
      preferences: data['preferences'] != null 
          ? List<String>.from(data['preferences'])
          : null,
      movingType: data['movingType'],
      numberOfRooms: data['numberOfRooms'],
      hasFurniture: data['hasFurniture'],
      needsPacking: data['needsPacking'],
      needsStorage: data['needsStorage'],
      specialRequirements: data['specialRequirements'],
      preferredMoverType: data['preferredMoverType'],
      maxBudget: (data['maxBudget'] is int)
          ? (data['maxBudget'] as int).toDouble()
          : data['maxBudget']?.toDouble(),
      timeline: data['timeline'],
      isVerified: data['isVerified'],
      verificationStatus: data['verificationStatus'],
      idDocumentUrl: data['idDocumentUrl'],
      proofOfAddressUrl: data['proofOfAddressUrl'],
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
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'about': about,
      'occupation': occupation,
      'company': company,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'preferences': preferences,
      'movingType': movingType,
      'numberOfRooms': numberOfRooms,
      'hasFurniture': hasFurniture,
      'needsPacking': needsPacking,
      'needsStorage': needsStorage,
      'specialRequirements': specialRequirements,
      'preferredMoverType': preferredMoverType,
      'maxBudget': maxBudget,
      'timeline': timeline,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'idDocumentUrl': idDocumentUrl,
      'proofOfAddressUrl': proofOfAddressUrl,
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
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? about,
    String? occupation,
    String? company,
    String? emergencyContact,
    String? emergencyPhone,
    List<String>? preferences,
    String? movingType,
    int? numberOfRooms,
    bool? hasFurniture,
    bool? needsPacking,
    bool? needsStorage,
    String? specialRequirements,
    String? preferredMoverType,
    double? maxBudget,
    String? timeline,
    bool? isVerified,
    String? verificationStatus,
    String? idDocumentUrl,
    String? proofOfAddressUrl,
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
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      about: about ?? this.about,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      preferences: preferences ?? this.preferences,
      movingType: movingType ?? this.movingType,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      hasFurniture: hasFurniture ?? this.hasFurniture,
      needsPacking: needsPacking ?? this.needsPacking,
      needsStorage: needsStorage ?? this.needsStorage,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      preferredMoverType: preferredMoverType ?? this.preferredMoverType,
      maxBudget: maxBudget ?? this.maxBudget,
      timeline: timeline ?? this.timeline,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      proofOfAddressUrl: proofOfAddressUrl ?? this.proofOfAddressUrl,
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
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      postalCode: map['postalCode'],
      about: map['about'],
      occupation: map['occupation'],
      company: map['company'],
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
      preferences: map['preferences'] != null 
          ? List<String>.from(map['preferences'])
          : null,
      movingType: map['movingType'],
      numberOfRooms: map['numberOfRooms'],
      hasFurniture: map['hasFurniture'],
      needsPacking: map['needsPacking'],
      needsStorage: map['needsStorage'],
      specialRequirements: map['specialRequirements'],
      preferredMoverType: map['preferredMoverType'],
      maxBudget: (map['maxBudget'] is int)
          ? (map['maxBudget'] as int).toDouble()
          : map['maxBudget']?.toDouble(),
      timeline: map['timeline'],
      isVerified: map['isVerified'],
      verificationStatus: map['verificationStatus'],
      idDocumentUrl: map['idDocumentUrl'],
      proofOfAddressUrl: map['proofOfAddressUrl'],
    );
  }
}