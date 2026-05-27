import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../core/config/app_config.dart';

class PurchasesService {
  static const _entitlementId = AppConfig.primeEntitlementId;

  // ── User identity ────────────────────────────────────────────────────────────

  Future<void> logIn(String uid) async {
    await Purchases.logIn(uid);
  }

  Future<void> logOut() async {
    await Purchases.logOut();
  }

  // ── Entitlement status ───────────────────────────────────────────────────────

  Future<bool> isPrime() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// Stream of customer info updates from RevenueCat.
  Stream<CustomerInfo> get customerInfoStream =>
      Purchases.customerInfoStream;

  // ── Paywall ──────────────────────────────────────────────────────────────────

  /// Shows the RevenueCat paywall. Returns true if a purchase or restore
  /// completed successfully.
  Future<bool> presentPaywall(BuildContext context) async {
    final result = await RevenueCatUI.presentPaywall(context: context);
    return result == PaywallResult.purchased || result == PaywallResult.restored;
  }

  /// Shows the paywall only if the user doesn't already have the entitlement.
  /// Returns true if they now have Prime (either purchased or already had it).
  Future<bool> presentPaywallIfNeeded(BuildContext context) async {
    final result = await RevenueCatUI.presentPaywallIfNeeded(
      context: context,
      requiredEntitlementIdentifier: _entitlementId,
    );
    return result == PaywallResult.purchased ||
        result == PaywallResult.restored ||
        result == PaywallResult.notPresented; // notPresented = already has it
  }

  // ── Customer Center ──────────────────────────────────────────────────────────

  /// Shows the RevenueCat Customer Center for subscription management,
  /// cancellations and refund requests.
  Future<void> presentCustomerCenter(BuildContext context) async {
    await RevenueCatUI.presentCustomerCenter(context: context);
  }

  // ── Manual purchase (fallback if no RC paywall template configured) ──────────

  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo.entitlements.active.containsKey(_entitlementId);
  }

  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(_entitlementId);
  }
}
