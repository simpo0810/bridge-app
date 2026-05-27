import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchases_service.dart';

final purchasesServiceProvider = Provider<PurchasesService>(
  (_) => PurchasesService(),
);

/// Available packages fetched from RevenueCat offerings.
final primePackagesProvider = FutureProvider<List<Package>>((ref) {
  return ref.watch(purchasesServiceProvider).getAvailablePackages();
});

// ── Purchase state machine ────────────────────────────────────────────────────

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

  Future<bool> purchasePrime(Package package) async {
    state = const PurchaseState(isLoading: true);
    try {
      final success = await _service.purchasePrime(package);
      state = const PurchaseState();
      return success;
    } on PurchasesError catch (e) {
      // User dismissed the paywall — not a real error
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        state = const PurchaseState();
        return false;
      }
      state = PurchaseState(error: e.message);
      return false;
    } catch (e) {
      state = PurchaseState(error: 'Purchase failed. Please try again.');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = const PurchaseState(isLoading: true);
    try {
      final success = await _service.restorePurchases();
      state = const PurchaseState();
      return success;
    } catch (e) {
      state =
          PurchaseState(error: 'Could not restore purchases. Please try again.');
      return false;
    }
  }

  void clearError() => state = const PurchaseState();
}

final purchaseNotifierProvider =
    StateNotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref.watch(purchasesServiceProvider)),
);
