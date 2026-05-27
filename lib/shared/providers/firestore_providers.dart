import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../models/exchange_rate.dart';
import '../models/transfer.dart';
import '../services/firestore_service.dart';
import 'auth_providers.dart';

final firestoreServiceProvider = Provider<FirestoreService>((_) => FirestoreService());

// ── Exchange Rates ─────────────────────────────────────────────────────────────

final exchangeRateProvider =
    StreamProvider.family<ExchangeRate, String>((ref, corridorId) {
  return ref.watch(firestoreServiceProvider).watchRate(corridorId);
});

// ── Contacts ───────────────────────────────────────────────────────────────────

final recentContactsProvider = StreamProvider<List<Contact>>((ref) {
  final uid = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchRecentContacts(uid);
});

final allContactsProvider = StreamProvider<List<Contact>>((ref) {
  final uid = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchContacts(uid);
});

// ── Transfers ──────────────────────────────────────────────────────────────────

final recentTransfersProvider = StreamProvider<List<Transfer>>((ref) {
  final uid = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchRecentTransfers(uid);
});

final transferDetailProvider =
    StreamProvider.family<Transfer?, String>((ref, transferId) {
  final uid = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchTransfer(uid, transferId);
});
