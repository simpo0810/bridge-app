import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/config/app_config.dart';

class PurchasesService {
  static const _entitlementId = AppConfig.primeEntitlementId;

  Future<bool> getInitialPrimeStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> purchasePrime(Package package) async {
    // v10 API: PurchaseParams.package(pkg) — named constructor, returns PurchaseResult
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo.entitlements.active.containsKey(_entitlementId);
  }

  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(_entitlementId);
  }
}
