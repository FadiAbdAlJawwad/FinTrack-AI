import 'package:flutter/material.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fin_track_ai/core/services/biometric_service.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:fin_track_ai/features/transactions/data/repositories/firestore_transaction_repository.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/wallets/data/repositories/firestore_wallet_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import 'package:fin_track_ai/core/routing/app_lock_notifier.dart';
import 'package:fin_track_ai/core/routing/app_lock_lifecycle_observer.dart';
import 'package:fin_track_ai/core/routing/router_generator.dart';
import 'package:fin_track_ai/core/constant/shared_prefs_keys.dart';
import 'package:fin_track_ai/core/routing/app_routes.dart';

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  void mockCurrentUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }
}

class MockUser extends Fake implements User {}

class FakeBiometricService extends Fake implements BiometricService {
  @override
  Future<bool> authenticate() async => false;
}

class DummyTxRepo extends Fake implements TransactionRepository {
  @override
  Stream<List<TransactionModel>> getTransactionsStream() => Stream.value([]);
}

class DummyCurrencyRepo extends Fake implements CurrencyRepository {
  @override
  Stream<String> watchBaseCurrency() => Stream.value('USD');
}

class DummyWalletRepo extends Fake implements WalletRepository {
  @override
  Stream<List<WalletModel>> getWalletsStream() => Stream.value([]);
}

void main() {
  group('AppLockNotifier', () {
    test('1. starts with the given state', () {
      final lock1 = AppLockNotifier(initialLocked: true);
      expect(lock1.isLocked, isTrue);

      final lock2 = AppLockNotifier(initialLocked: false);
      expect(lock2.isLocked, isFalse);
    });

    test('2. lock()/unlock() notify only on change', () {
      final lock = AppLockNotifier(initialLocked: false);
      int notifyCount = 0;
      lock.addListener(() => notifyCount++);

      lock.unlock(); // already false, should not notify
      expect(notifyCount, 0);

      lock.lock(); // changes to true
      expect(lock.isLocked, isTrue);
      expect(notifyCount, 1);

      lock.lock(); // already true, should not notify
      expect(notifyCount, 1);

      lock.unlock(); // changes to false
      expect(lock.isLocked, isFalse);
      expect(notifyCount, 2);
    });
  });

  group('Router redirect', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late SharedPreferences prefs;

    setUp(() async {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    GoRouter createRouter(AppLockNotifier lock) {
      return RouteGenerator.build(
        firebaseAuth: mockAuth,
        prefs: prefs,
        lock: lock,
      );
    }

    Widget buildTestApp(GoRouter router, AppLockNotifier lock) {
      return ProviderScope(
        overrides: [
          appLockNotifierProvider.overrideWithValue(lock),
          biometricServiceProvider.overrideWithValue(FakeBiometricService()),
          currentUserProvider.overrideWithValue(
            const UserModel(
              uid: '123',
              email: 'test@test.com',
              fullName: 'Test',
            ),
          ),
          sharedPrefsProvider.overrideWithValue(prefs),
          transactionRepositoryProvider.overrideWithValue(DummyTxRepo()),
          currencyRepositoryProvider.overrideWithValue(DummyCurrencyRepo()),
          walletRepositoryProvider.overrideWithValue(DummyWalletRepo()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets(
      '3. signed in + biometric on + locked + target /home -> redirected to lockScreen',
      (tester) async {
        mockAuth.mockCurrentUser(mockUser);
        await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
        await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);
        final lock = AppLockNotifier(initialLocked: true);

        final router = createRouter(lock);
        await tester.pumpWidget(buildTestApp(router, lock));
        router.go(AppRoutes.homeScreen);
        await tester.pumpAndSettle();

        final lastMatch = router.routerDelegate.currentConfiguration.last;
        expect(lastMatch.route.path, AppRoutes.lockScreen);
      },
    );

    testWidgets('4. same but unlocked -> stays', (tester) async {
      mockAuth.mockCurrentUser(mockUser);
      await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
      await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);
      final lock = AppLockNotifier(initialLocked: false);

      final router = createRouter(lock);
      await tester.pumpWidget(buildTestApp(router, lock));
      router.go(AppRoutes.homeScreen);
      await tester.pumpAndSettle();

      final lastMatch = router.routerDelegate.currentConfiguration.last;
      expect(lastMatch.route.path, AppRoutes.homeScreen);
    });

    testWidgets('5. lockScreen while unlocked -> redirected to home', (
      tester,
    ) async {
      mockAuth.mockCurrentUser(mockUser);
      await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
      await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);

      // Start locked so we get to lockScreen
      final lock = AppLockNotifier(initialLocked: true);
      final router = createRouter(lock);
      await tester.pumpWidget(buildTestApp(router, lock));
      router.go(AppRoutes.homeScreen);
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.route.path,
        AppRoutes.lockScreen,
      );

      // Now unlock it, the router should refresh and redirect to home
      lock.unlock();
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.route.path,
        AppRoutes.homeScreen,
      );
    });

    testWidgets(
      '6. biometric off -> never redirected to lockScreen even if locked',
      (tester) async {
        mockAuth.mockCurrentUser(mockUser);
        await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
        await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, false);
        final lock = AppLockNotifier(initialLocked: true); // Locked!

        final router = createRouter(lock);
        await tester.pumpWidget(buildTestApp(router, lock));
        router.go(AppRoutes.homeScreen);
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.route.path,
          AppRoutes.homeScreen,
        );
      },
    );

    testWidgets('7. signed out -> login (unchanged)', (tester) async {
      mockAuth.mockCurrentUser(null);
      await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
      final lock = AppLockNotifier(initialLocked: false);

      final router = createRouter(lock);
      await tester.pumpWidget(buildTestApp(router, lock));
      router.go(AppRoutes.homeScreen);
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.route.path,
        AppRoutes.login,
      );
    });
  });

  group('Lifecycle', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late SharedPreferences prefs;
    late AppLockNotifier lock;
    DateTime currentTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() async {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      lock = AppLockNotifier(initialLocked: false);
    });

    Widget buildObserver() {
      return MaterialApp(
        home: AppLockLifecycleObserver(
          appLockNotifier: lock,
          firebaseAuth: mockAuth,
          prefs: prefs,
          getCurrentTime: () => currentTime,
          child: const Scaffold(body: Text('Observer test')),
        ),
      );
    }

    testWidgets('8. resumed after 31 s -> locked', (tester) async {
      mockAuth.mockCurrentUser(mockUser);
      await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);

      await tester.pumpWidget(buildObserver());

      final observerState = tester.state<State<AppLockLifecycleObserver>>(
        find.byType(AppLockLifecycleObserver),
      );
      final observer = observerState as WidgetsBindingObserver;

      currentTime = DateTime(2025, 1, 1, 12, 0, 0);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      currentTime = DateTime(2025, 1, 1, 12, 0, 31);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(lock.isLocked, isTrue);
    });

    testWidgets('9. resumed after 10 s -> not locked', (tester) async {
      mockAuth.mockCurrentUser(mockUser);
      await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);

      await tester.pumpWidget(buildObserver());

      final observerState = tester.state<State<AppLockLifecycleObserver>>(
        find.byType(AppLockLifecycleObserver),
      );
      final observer = observerState as WidgetsBindingObserver;

      currentTime = DateTime(2025, 1, 1, 12, 0, 0);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      currentTime = DateTime(2025, 1, 1, 12, 0, 10);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(lock.isLocked, isFalse);
    });

    testWidgets('10. signed out or biometric off -> never locks', (
      tester,
    ) async {
      mockAuth.mockCurrentUser(null); // Signed out
      await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);

      await tester.pumpWidget(buildObserver());

      final observerState = tester.state<State<AppLockLifecycleObserver>>(
        find.byType(AppLockLifecycleObserver),
      );
      final observer = observerState as WidgetsBindingObserver;

      currentTime = DateTime(2025, 1, 1, 12, 0, 0);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      currentTime = DateTime(2025, 1, 1, 12, 0, 31);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(lock.isLocked, isFalse);

      mockAuth.mockCurrentUser(mockUser); // Signed in
      await prefs.setBool(
        SharedPrefsKeys.isBiometricEnabledKey,
        false,
      ); // Biometric off

      currentTime = DateTime(2025, 1, 1, 12, 0, 0);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      currentTime = DateTime(2025, 1, 1, 12, 0, 31);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(lock.isLocked, isFalse);
    });

    testWidgets(
      '11. tester.binding.handleAppLifecycleStateChanged proves observer is registered',
      (tester) async {
        mockAuth.mockCurrentUser(mockUser);
        await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);

        await tester.pumpWidget(buildObserver());

        currentTime = DateTime(2025, 1, 1, 12, 0, 0);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

        currentTime = DateTime(2025, 1, 1, 12, 0, 31);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );

        expect(lock.isLocked, isTrue);
      },
    );
  });
}
