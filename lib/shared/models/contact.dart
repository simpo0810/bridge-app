import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String country;
  final String countryEmoji;
  final String deliveryMethod;
  final String walletProvider;
  final int transferCount;
  final DateTime? lastUsedAt;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.country,
    required this.countryEmoji,
    required this.deliveryMethod,
    required this.walletProvider,
    this.transferCount = 0,
    this.lastUsedAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty && parts.first.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }

  factory Contact.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Contact(
      id: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      country: d['country'] ?? '',
      countryEmoji: d['countryEmoji'] ?? '',
      deliveryMethod: d['deliveryMethod'] ?? '',
      walletProvider: d['walletProvider'] ?? '',
      transferCount: (d['transferCount'] as int?) ?? 0,
      lastUsedAt: (d['lastUsedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'country': country,
        'countryEmoji': countryEmoji,
        'deliveryMethod': deliveryMethod,
        'walletProvider': walletProvider,
        'transferCount': transferCount,
        'lastUsedAt': lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
      };
}
