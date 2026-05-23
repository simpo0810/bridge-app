import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/onboarding/splash_screen.dart';
import '../../features/auth/onboarding/welcome_screen.dart';
import '../../features/auth/onboarding/phone_screen.dart';
import '../../features/auth/onboarding/otp_screen.dart';
import '../../features/auth/onboarding/email_password_screen.dart';
import '../../features/auth/onboarding/personal_info_screen.dart';
import '../../features/auth/onboarding/address_screen.dart';
import '../../features/auth/onboarding/id_upload_screen.dart';
import '../../features/auth/onboarding/selfie_screen.dart';
import '../../features/auth/onboarding/pending_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/biometric/biometric_prompt_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/contacts/contacts_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/manage/manage_screen.dart';
import '../../features/manage/profile/profile_screen.dart';
import '../../features/manage/settings/settings_screen.dart';
import '../../features/manage/payment_methods/payment_methods_screen.dart';
import '../../features/manage/prime/prime_screen.dart';
import '../../shared/providers/auth_providers.dart';
import '../shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return '/splash';

      final user = authState.valueOrNull;
      final isAuthed = user != null;
      final onAuthRoute = state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/splash';

      if (!isAuthed && !onAuthRoute) return '/welcome';
      if (isAuthed && onAuthRoute && state.matchedLocation != '/onboarding/pending') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/login/biometric',
        builder: (_, __) => const BiometricPromptScreen(),
      ),

      // Onboarding sub-routes
      GoRoute(
        path: '/onboarding/phone',
        builder: (_, __) => const PhoneScreen(),
      ),
      GoRoute(
        path: '/onboarding/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            verificationId: extra?['verificationId'] ?? '',
            phone: extra?['phone'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/onboarding/email-password',
        builder: (_, __) => const EmailPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding/personal-info',
        builder: (_, __) => const PersonalInfoScreen(),
      ),
      GoRoute(path: '/onboarding/address', builder: (_, __) => const AddressScreen()),
      GoRoute(path: '/onboarding/id-upload', builder: (_, __) => const IdUploadScreen()),
      GoRoute(path: '/onboarding/selfie', builder: (_, __) => const SelfieScreen()),
      GoRoute(path: '/onboarding/pending', builder: (_, __) => const PendingScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/contacts', builder: (_, __) => const ContactsScreen()),
          GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
          GoRoute(
            path: '/manage',
            builder: (_, __) => const ManageScreen(),
            routes: [
              GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
              GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
              GoRoute(
                path: 'payment-methods',
                builder: (_, __) => const PaymentMethodsScreen(),
              ),
              GoRoute(path: 'prime', builder: (_, __) => const PrimeScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});
