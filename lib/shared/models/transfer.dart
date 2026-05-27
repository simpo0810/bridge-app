import 'package:cloud_firestore/cloud_firestore.dart';

class Transfer {
  final String id;
  final TransferStatus status;
  final double amountCAD;
  final double feeCAD;
  final double totalCAD;
  final double amountLocal;
  final String currency;
  final double exchangeRate;
  final String deliveryMethod;
  final String paymentMethod;
  final RecipientSnapshot recipient;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Transfer({
    required this.id,
    required this.status,
    required this.amountCAD,
    required this.feeCAD,
    required this.totalCAD,
    required this.amountLocal,
    required this.currency,
    required this.exchangeRate,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.recipient,
    required this.createdAt,
    this.completedAt,
  });

  factory Transfer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Transfer(
      id: doc.id,
      status: TransferStatus.values.firstWhere(
        (e) => e.name == (d['status'] ?? 'pending'),
        orElse: () => TransferStatus.pending,
      ),
      amountCAD: (d['amountCAD'] as num?)?.toDouble() ?? 0,
      feeCAD: (d['feeCAD'] as num?)?.toDouble() ?? 0,
      totalCAD: (d['totalCAD'] as num?)?.toDouble() ?? 0,
      amountLocal: (d['amountLocal'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] ?? '',
      exchangeRate: (d['exchangeRate'] as num?)?.toDouble() ?? 0,
      deliveryMethod: d['deliveryMethod'] ?? '',
      paymentMethod: d['paymentMethod'] ?? '',
      recipient: RecipientSnapshot.fromMap(
          (d['recipientSnapshot'] as Map<String, dynamic>?) ?? {}),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class RecipientSnapshot {
  final String name;
  final String phone;
  final String country;
  final String countryEmoji;
  final String wallet;

  const RecipientSnapshot({
    required this.name,
    required this.phone,
    required this.country,
    required this.countryEmoji,
    required this.wallet,
  });

  factory RecipientSnapshot.fromMap(Map<String, dynamic> m) => RecipientSnapshot(
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        country: m['country'] ?? '',
        countryEmoji: m['countryEmoji'] ?? '',
        wallet: m['wallet'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'country': country,
        'countryEmoji': countryEmoji,
        'wallet': wallet,
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty && parts.first.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }
}

enum TransferStatus { pending, processing, delivered, failed }

extension TransferStatusX on TransferStatus {
  String get label {
    switch (this) {
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.processing:
        return 'Processing';
      case TransferStatus.delivered:
        return 'Delivered';
      case TransferStatus.failed:
        return 'Failed';
    }
  }
}
