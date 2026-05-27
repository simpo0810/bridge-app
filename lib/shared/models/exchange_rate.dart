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

  // Fallback rates used when Firestore is unavailable or the doc doesn't exist yet.
  // Keep these in sync with real market rates periodically.
  static const _fallbackRates = {
    'CAD_KES': (rate: 92.50, standard: 91.00, prime: 93.50),
    'CAD_CDF': (rate: 2045.0, standard: 2020.0, prime: 2065.0),
    'CAD_RWF': (rate: 800.0, standard: 790.0, prime: 812.0),
    'CAD_NGN': (rate: 890.0, standard: 878.0, prime: 902.0),
    'CAD_GHS': (rate: 8.90, standard: 8.75, prime: 9.05),
    'CAD_XOF': (rate: 410.0, standard: 405.0, prime: 416.0),
  };

  factory ExchangeRate.fallback(String corridorId) {
    final f = _fallbackRates[corridorId];
    return ExchangeRate(
      corridorId: corridorId,
      rate: f?.rate ?? 0,
      standardRate: f?.standard ?? 0,
      primeRate: f?.prime ?? 0,
      updatedAt: DateTime.now(),
    );
  }
}
