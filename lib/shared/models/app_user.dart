import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final UserAddress? address;
  final KycStatus kycStatus;
  final bool isPrime;
  final DateTime? primeExpiresAt;
  final String preferredCountry;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.address,
    required this.kycStatus,
    required this.isPrime,
    this.primeExpiresAt,
    required this.preferredCountry,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      address: data['address'] != null
          ? UserAddress.fromMap(data['address'] as Map<String, dynamic>)
          : null,
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == (data['kycStatus'] ?? 'pending'),
        orElse: () => KycStatus.pending,
      ),
      isPrime: data['isPrime'] ?? false,
      primeExpiresAt: (data['primeExpiresAt'] as Timestamp?)?.toDate(),
      preferredCountry: data['preferredCountry'] ?? 'KE',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
        'address': address?.toMap(),
        'kycStatus': kycStatus.name,
        'isPrime': isPrime,
        'primeExpiresAt':
            primeExpiresAt != null ? Timestamp.fromDate(primeExpiresAt!) : null,
        'preferredCountry': preferredCountry,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    UserAddress? address,
    KycStatus? kycStatus,
    bool? isPrime,
    DateTime? primeExpiresAt,
    String? preferredCountry,
  }) =>
      AppUser(
        uid: uid,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        address: address ?? this.address,
        kycStatus: kycStatus ?? this.kycStatus,
        isPrime: isPrime ?? this.isPrime,
        primeExpiresAt: primeExpiresAt ?? this.primeExpiresAt,
        preferredCountry: preferredCountry ?? this.preferredCountry,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class UserAddress {
  final String street;
  final String city;
  final String province;
  final String postalCode;

  const UserAddress({
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
  });

  factory UserAddress.fromMap(Map<String, dynamic> map) => UserAddress(
        street: map['street'] ?? '',
        city: map['city'] ?? '',
        province: map['province'] ?? '',
        postalCode: map['postalCode'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'street': street,
        'city': city,
        'province': province,
        'postalCode': postalCode,
      };

  @override
  String toString() => '$street, $city, $province $postalCode';
}

enum KycStatus { pending, verified, rejected }
