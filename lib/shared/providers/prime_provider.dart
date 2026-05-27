import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchases_service.dart';
import 'auth_providers.dart';

final purchasesServiceProvider = Provider<PurchasesService>(
  (_) => PurchasesService(),
);

// ── RC ↔ Firebase Auth sync ──────────────────────────────────────────────────

/// Watches Firebase Auth state and keeps RevenueCat user identity in sync.
/// Watch this provider from the root widget to activate it for the app lifetime.
final rcUserSyncProvider = Provider<void>((ref) {
  ref.watch(firebaseAuthStateProvider).whenData((user) async {
    final service = ref.read(purchasesServiceProvider);
    if (user != null) {
      await service.logIn(user.uid);
    } else {
      await service.logOut();
    }
  });
});

// ── Live customer info from RevenueCat ───────────────────────────────────────

final rcCustomerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  return ref.watch(purchasesServiceProvider).customerInfoStream;
});

// ── Available packages ───────────────────────────────────────────────────────

final primePackagesProvider = FutureProvider<List<Package>>((ref) {
  return ref.watch(purchasesServiceProvider).getAvailablePackages();
});

// ── Purchase state machine ───────────────────────────────────────────────────

class PurchaseState {
  final bool isLoading;
  final String? error;
  const PurchaseState({this.isLoading = false, this.error});

  PurchaseState copyWith({bool? isLoading, String? error}) =>
      PurchaseState(isLoading: isLoading ?? this.isLoading, error: error);
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PurchasesService _service;

  PurchaseNotifier(this._service) : super(const PurchaseState());

  Future<bool> purchasePackage(Package package) async {
    state = const PurchaseState(isLoading: true);
    try {
      final success = await _service.purchasePackage(package);
      state = const PurchaseState();
      return success;
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        state = const PurchaseState();
        return false;
      }
      state = PurchaseState(error: e.message);
      return false;
    } catch (_) {
      state = const PurchaseState(error: 'Purchase failed. Please try again.');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = const PurchaseState(isLoading: true);
    try {
      final success = await _service.restorePurchases();
      state = const PurchaseState();
      return success;
    } catch (_) {
      state = const PurchaseState(
          error: 'Could not restore purchases. Please try again.');
      return false;
    }
  }

  void clearError() => state = const PurchaseState();
}

final purchaseNotifierProvider =
    StateNotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref.watch(purchasesServiceProvider)),
);
