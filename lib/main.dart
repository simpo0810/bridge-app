import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'shared/providers/prime_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configureRevenueCat();
  runApp(const ProviderScope(child: BridgeApp()));
}

Future<void> _configureRevenueCat() async {
  if (!Platform.isIOS && !Platform.isAndroid) return;

  await Purchases.setLogLevel(LogLevel.debug);

  final apiKey = Platform.isIOS
      ? AppConfig.revenueCatIosKey
      : AppConfig.revenueCatAndroidKey;

  final configuration = PurchasesConfiguration(apiKey);
  await Purchases.configure(configuration);

  // If the user is already signed in (app restart), identify them in RC
  // immediately so entitlements are available before the first frame.
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await Purchases.logIn(user.uid);
  }
}

class BridgeApp extends ConsumerWidget {
  const BridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps RevenueCat user identity in sync with Firebase Auth state.
    ref.watch(rcUserSyncProvider);

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Bridge',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
