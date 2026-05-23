import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

// Raw Firebase auth stream
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Full AppUser document from Firestore, kept in sync
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(authServiceProvider).watchUser(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final isBiometricAvailableProvider = FutureProvider<bool>((ref) =>
    ref.watch(biometricServiceProvider).isAvailable());
