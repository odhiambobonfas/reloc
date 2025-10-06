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
  
  // Enhanced business fields
  final String? businessName;
  final String? businessLicense;
  final String? taxId;
  final String? insuranceNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? serviceRadius; // in kilometers
  final List<String>? services; // ['residential', 'commercial', 'international', 'packing', 'storage']
  final List<String>? specializations; // ['furniture', 'electronics', 'art', 'pianos', 'vehicles']
  final String? experience; // 'beginner', 'intermediate', 'expert'
  final int? yearsOfExperience;
  final String? about;
  final String? companySize; // 'individual', 'small_team', 'large_company'
  final int? teamSize;
  final List<String>? certifications;
  final List<String>? languages;
  final String? availability; // 'full_time', 'part_time', 'on_demand'
  final Map<String, dynamic>? workingHours;
  final bool? isVerified;
  final String? verificationStatus; // 'pending', 'verified', 'rejected'
  final String? idDocumentUrl;
  final String? businessLicenseUrl;
  final String? insuranceDocumentUrl;
  final String? vehiclePhotos; // comma-separated URLs
  final String? equipmentList;
  final double? minJobValue;
  final double? maxJobValue;
  final String? paymentMethods; // comma-separated
  final bool? providesQuotes;
  final String? responseTime; // 'immediate', 'within_hour', 'within_day'
  final List<String>? acceptedPaymentTypes;
  final String? cancellationPolicy;
  final double? cancellationFee;
  final String? emergencyContact;
  final String? emergencyPhone;

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
    this.businessName,
    this.businessLicense,
    this.taxId,
    this.insuranceNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.serviceRadius,
    this.services,
    this.specializations,
    this.experience,
    this.yearsOfExperience,
    this.about,
    this.companySize,
    this.teamSize,
    this.certifications,
    this.languages,
    this.availability,
    this.workingHours,
    this.isVerified,
    this.verificationStatus,
    this.idDocumentUrl,
    this.businessLicenseUrl,
    this.insuranceDocumentUrl,
    this.vehiclePhotos,
    this.equipmentList,
    this.minJobValue,
    this.maxJobValue,
    this.paymentMethods,
    this.providesQuotes,
    this.responseTime,
    this.acceptedPaymentTypes,
    this.cancellationPolicy,
    this.cancellationFee,
    this.emergencyContact,
    this.emergencyPhone,
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
      businessName: data['businessName'],
      businessLicense: data['businessLicense'],
      taxId: data['taxId'],
      insuranceNumber: data['insuranceNumber'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      postalCode: data['postalCode'],
      latitude: (data['latitude'] is int) ? (data['latitude'] as int).toDouble() : data['latitude']?.toDouble(),
      longitude: (data['longitude'] is int) ? (data['longitude'] as int).toDouble() : data['longitude']?.toDouble(),
      serviceRadius: data['serviceRadius'],
      services: data['services'] != null ? List<String>.from(data['services']) : null,
      specializations: data['specializations'] != null ? List<String>.from(data['specializations']) : null,
      experience: data['experience'],
      yearsOfExperience: data['yearsOfExperience'],
      about: data['about'],
      companySize: data['companySize'],
      teamSize: data['teamSize'],
      certifications: data['certifications'] != null ? List<String>.from(data['certifications']) : null,
      languages: data['languages'] != null ? List<String>.from(data['languages']) : null,
      availability: data['availability'],
      workingHours: data['workingHours'],
      isVerified: data['isVerified'],
      verificationStatus: data['verificationStatus'],
      idDocumentUrl: data['idDocumentUrl'],
      businessLicenseUrl: data['businessLicenseUrl'],
      insuranceDocumentUrl: data['insuranceDocumentUrl'],
      vehiclePhotos: data['vehiclePhotos'],
      equipmentList: data['equipmentList'],
      minJobValue: (data['minJobValue'] is int) ? (data['minJobValue'] as int).toDouble() : data['minJobValue']?.toDouble(),
      maxJobValue: (data['maxJobValue'] is int) ? (data['maxJobValue'] as int).toDouble() : data['maxJobValue']?.toDouble(),
      paymentMethods: data['paymentMethods'],
      providesQuotes: data['providesQuotes'],
      responseTime: data['responseTime'],
      acceptedPaymentTypes: data['acceptedPaymentTypes'] != null ? List<String>.from(data['acceptedPaymentTypes']) : null,
      cancellationPolicy: data['cancellationPolicy'],
      cancellationFee: (data['cancellationFee'] is int) ? (data['cancellationFee'] as int).toDouble() : data['cancellationFee']?.toDouble(),
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
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
      'businessName': businessName,
      'businessLicense': businessLicense,
      'taxId': taxId,
      'insuranceNumber': insuranceNumber,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'serviceRadius': serviceRadius,
      'services': services,
      'specializations': specializations,
      'experience': experience,
      'yearsOfExperience': yearsOfExperience,
      'about': about,
      'companySize': companySize,
      'teamSize': teamSize,
      'certifications': certifications,
      'languages': languages,
      'availability': availability,
      'workingHours': workingHours,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'idDocumentUrl': idDocumentUrl,
      'businessLicenseUrl': businessLicenseUrl,
      'insuranceDocumentUrl': insuranceDocumentUrl,
      'vehiclePhotos': vehiclePhotos,
      'equipmentList': equipmentList,
      'minJobValue': minJobValue,
      'maxJobValue': maxJobValue,
      'paymentMethods': paymentMethods,
      'providesQuotes': providesQuotes,
      'responseTime': responseTime,
      'acceptedPaymentTypes': acceptedPaymentTypes,
      'cancellationPolicy': cancellationPolicy,
      'cancellationFee': cancellationFee,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
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
    String? businessName,
    String? businessLicense,
    String? taxId,
    String? insuranceNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? serviceRadius,
    List<String>? services,
    List<String>? specializations,
    String? experience,
    int? yearsOfExperience,
    String? about,
    String? companySize,
    int? teamSize,
    List<String>? certifications,
    List<String>? languages,
    String? availability,
    Map<String, dynamic>? workingHours,
    bool? isVerified,
    String? verificationStatus,
    String? idDocumentUrl,
    String? businessLicenseUrl,
    String? insuranceDocumentUrl,
    String? vehiclePhotos,
    String? equipmentList,
    double? minJobValue,
    double? maxJobValue,
    String? paymentMethods,
    bool? providesQuotes,
    String? responseTime,
    List<String>? acceptedPaymentTypes,
    String? cancellationPolicy,
    double? cancellationFee,
    String? emergencyContact,
    String? emergencyPhone,
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
      businessName: businessName ?? this.businessName,
      businessLicense: businessLicense ?? this.businessLicense,
      taxId: taxId ?? this.taxId,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      services: services ?? this.services,
      specializations: specializations ?? this.specializations,
      experience: experience ?? this.experience,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      about: about ?? this.about,
      companySize: companySize ?? this.companySize,
      teamSize: teamSize ?? this.teamSize,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      availability: availability ?? this.availability,
      workingHours: workingHours ?? this.workingHours,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      businessLicenseUrl: businessLicenseUrl ?? this.businessLicenseUrl,
      insuranceDocumentUrl: insuranceDocumentUrl ?? this.insuranceDocumentUrl,
      vehiclePhotos: vehiclePhotos ?? this.vehiclePhotos,
      equipmentList: equipmentList ?? this.equipmentList,
      minJobValue: minJobValue ?? this.minJobValue,
      maxJobValue: maxJobValue ?? this.maxJobValue,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      providesQuotes: providesQuotes ?? this.providesQuotes,
      responseTime: responseTime ?? this.responseTime,
      acceptedPaymentTypes: acceptedPaymentTypes ?? this.acceptedPaymentTypes,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }
}

