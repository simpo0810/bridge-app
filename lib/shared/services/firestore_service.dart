import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';
import '../models/exchange_rate.dart';
import '../models/transfer.dart';

/// All Firestore reads are centralised here.
/// No client-side writes to financial data — those go through Cloud Functions.
class FirestoreService {
  final FirebaseFirestore _db;
  static const int _pageSize = 20;

  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Exchange rates ──────────────────────────────────────────────────────────

  Stream<ExchangeRate> watchRate(String corridorId) => _db
      .collection('exchangeRates')
      .doc(corridorId)
      .withConverter<ExchangeRate>(
        fromFirestore: (s, _) => ExchangeRate.fromFirestore(s),
        toFirestore: (_, __) => {},
      )
      .snapshots()
      .map((s) => s.data() ?? ExchangeRate.fallback(corridorId));

  Future<ExchangeRate> getRate(String corridorId) async {
    final snap = await _db.collection('exchangeRates').doc(corridorId).get();
    if (!snap.exists) return ExchangeRate.fallback(corridorId);
    return ExchangeRate.fromFirestore(snap);
  }

  // ── Contacts ────────────────────────────────────────────────────────────────

  /// Paginated, ordered by last used — clients can safely call this with
  /// unlimited users because each query is bounded by [_pageSize].
  Stream<List<Contact>> watchContacts(String uid, {DocumentSnapshot? startAfter}) {
    var q = _db
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .orderBy('lastUsedAt', descending: true)
        .limit(_pageSize);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.snapshots().map(
          (snap) => snap.docs
              .map((d) => Contact.fromFirestore(d))
              .toList(),
        );
  }

  /// Quick send — the 4 most recently used contacts, cached by Firestore offline.
  Stream<List<Contact>> watchRecentContacts(String uid, {int limit = 4}) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .orderBy('lastUsedAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map((d) => Contact.fromFirestore(d)).toList());

  Future<void> saveContact(String uid, Contact contact) => _db
      .collection('users')
      .doc(uid)
      .collection('contacts')
      .doc(contact.id.isEmpty ? null : contact.id)
      .set(contact.toFirestore(), SetOptions(merge: true));

  Future<void> deleteContact(String uid, String contactId) =>
      _db.collection('users').doc(uid).collection('contacts').doc(contactId).delete();

  // ── Transfers ───────────────────────────────────────────────────────────────

  /// Paginated transfer history. Uses cursor pagination — never offset.
  Future<({List<Transfer> items, DocumentSnapshot? cursor})> getTransfers(
    String uid, {
    DocumentSnapshot? startAfter,
  }) async {
    var q = _db
        .collection('users')
        .doc(uid)
        .collection('transfers')
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);
    if (startAfter != null) q = q.startAfterDocument(startAfter);

    final snap = await q.get();
    return (
      items: snap.docs.map((d) => Transfer.fromFirestore(d)).toList(),
      cursor: snap.docs.isNotEmpty ? snap.docs.last : null,
    );
  }

  /// Real-time updates for a single transfer (status tracking).
  Stream<Transfer?> watchTransfer(String uid, String transferId) => _db
      .collection('users')
      .doc(uid)
      .collection('transfers')
      .doc(transferId)
      .withConverter<Transfer>(
        fromFirestore: (s, _) => Transfer.fromFirestore(s),
        toFirestore: (_, __) => {},
      )
      .snapshots()
      .map((s) => s.data());

  /// The 3 most recent transfers for the home screen preview.
  Stream<List<Transfer>> watchRecentTransfers(String uid, {int limit = 5}) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('transfers')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map((d) => Transfer.fromFirestore(d)).toList());
}
