import 'dart:async';

import 'app_routes.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/screens/lock_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/reset_password.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/transactions/presentation/screens/transaction_details.dart';
import '../../features/transactions/presentation/screens/voice_entry_screen.dart';
import '../constant/shared_prefs_keys.dart';
import 'app_lock_notifier.dart';
import 'main_shell_route.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RouteGenerator {
  static GoRouter build({
    required FirebaseAuth firebaseAuth,
    required SharedPreferences prefs,
    required AppLockNotifier lock,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(firebaseAuth.authStateChanges()),
        lock,
      ]),
      redirect: (context, state) async {
        final user = firebaseAuth.currentUser;

        final bool hasSeenOnboarding =
            prefs.getBool(SharedPrefsKeys.hasSeenOnboardingKey) ?? false;
        final bool isBiometricEnabled =
            prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey) ?? false;

        if (state.matchedLocation == AppRoutes.splash) {
          return null;
        }

        final bool isAuthScreen =
            state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.signup ||
            state.matchedLocation == AppRoutes.onboarding ||
            state.matchedLocation == AppRoutes.resetPassword ||
            state.matchedLocation == AppRoutes.splash;

        if (!hasSeenOnboarding) {
          return state.matchedLocation == AppRoutes.onboarding
              ? null
              : AppRoutes.onboarding;
        }

        if (user == null) {
          return isAuthScreen ? null : AppRoutes.login;
        }

        if (isBiometricEnabled &&
            lock.isLocked &&
            state.matchedLocation != AppRoutes.lockScreen) {
          return AppRoutes.lockScreen;
        }

        if (state.matchedLocation == AppRoutes.lockScreen && !lock.isLocked) {
          return AppRoutes.homeScreen;
        }

        if (isAuthScreen) {
          return AppRoutes.homeScreen;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          name: AppRoutes.signupName,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          name: AppRoutes.resetPasswordName,
          builder: (context, state) => const ResetPassword(),
        ),
        GoRoute(
          path: AppRoutes.lockScreen,
          name: AppRoutes.lockScreenName,
          builder: (context, state) => const LockScreen(),
        ),
        buildMainShellRoute(),
        GoRoute(
          path: AppRoutes.transactionsScreen,
          name: AppRoutes.transactionsScreenName,
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: AppRoutes.transactionDetailsWithId,
          name: AppRoutes.transactionDetailsName,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TransactionDetails(transactionId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.voiceEntry,
          name: AppRoutes.voiceEntryName,
          builder: (context, state) => const VoiceEntryScreen(),
        ),
      ],
    );
  }
}
