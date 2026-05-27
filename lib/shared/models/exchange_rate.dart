import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeRate {
  final String corridorId;
  final double rate;
  final double standardRate;
  final double primeRate;
  final DateTime updatedAt;

  const ExchangeRate({
    required this.corridorId,
    required this.rate,
    required this.standardRate,
    required this.primeRate,
    required this.updatedAt,
  });

  factory ExchangeRate.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ExchangeRate(
      corridorId: doc.id,
      rate: (d['rate'] as num?)?.toDouble() ?? 0,
      standardRate: (d['standardRate'] as num?)?.toDouble() ?? 0,
      primeRate: (d['primeRate'] as num?)?.toDouble() ?? 0,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Fallback constructor when Firestore is unavailable
  factory ExchangeRate.fallback(String corridorId) => ExchangeRate(
        corridorId: corridorId,
        rate: 0,
        standardRate: 0,
        primeRate: 0,
        updatedAt: DateTime.now(),
      );
}
