import 'package:fin_track_ai/core/providers/locale_provider.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/core/providers/theme_provider.dart';
import 'package:fin_track_ai/core/services/biometric_service.dart';
import 'package:fin_track_ai/core/theme/app_theme.dart';
import 'package:fin_track_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';
import 'package:fin_track_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/currency/presentation/widgets/currency_selector_dialog.dart';
import 'package:fin_track_ai/features/dashboard/presentation/screens/home_screen.dart';
import 'package:fin_track_ai/features/dashboard/presentation/state/dashboard_controller.dart';
import 'package:fin_track_ai/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:fin_track_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_ai/core/routing/app_lock_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBiometricService extends Fake implements BiometricService {
  bool shouldAuthenticate = true;
  bool shouldThrow = false;
  int authenticateCalls = 0;

  @override
  Future<bool> authenticate() async {
    authenticateCalls++;
    if (shouldThrow) {
      throw Exception('Biometric failure');
    }
    return shouldAuthenticate;
  }
}

class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository(this.base);
  final String base;

  @override
  Stream<String> watchBaseCurrency() => Stream.value(base);

  @override
  Future<void> setBaseCurrency(String currency) async {}
}

class FakeAuthRepository implements AuthRepositoryInterface {
  FakeAuthRepository({this.user});
  final UserModel? user;

  int signOutCount = 0;

  @override
  UserModel? get currentUser => user;

  @override
  Future<void> signOut() async {
    signOutCount++;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<UserModel> signIn(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<UserModel> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserModel> signUp(
    String fullName,
    String email,
    String password,
  ) async => throw UnimplementedError();
}

Widget createTestWidget({
  required SharedPreferences prefs,
  required FakeAuthRepository authRepo,
  required FakeBiometricService biometricService,
  String currency = 'USD',
  Widget child = const SettingsScreen(),
}) {
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(authRepo),
      currentUserProvider.overrideWithValue(authRepo.currentUser),
      biometricServiceProvider.overrideWithValue(biometricService),
      currencyRepositoryProvider.overrideWithValue(
        FakeCurrencyRepository(currency),
      ),
      appLockNotifierProvider.overrideWithValue(
        AppLockNotifier(initialLocked: false),
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(localeProvider);
        final themeMode = ref.watch(themeProvider);
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: AppTheme.lightTheme(locale.languageCode),
          darkTheme: AppTheme.darkTheme(locale.languageCode),
          themeMode: themeMode,
          home: child,
        );
      },
    ),
  );
}

void main() {
  testWidgets(
    '1. Settings screen renders the three section titles/tiles in English and user name',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository(
        user: const UserModel(
          uid: 'u1',
          email: 'john@example.com',
          fullName: 'John Doe',
        ),
      );
      final biometricService = FakeBiometricService();

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authRepo: authRepo,
          biometricService: biometricService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('APP PREFERENCES'), findsOneWidget);
      expect(find.text('SECURITY'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Biometric Authentication'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    },
  );

  testWidgets("2. Same screen with Locale('ar') renders Arabic labels", (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'locale_code': 'ar'});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository(
      user: const UserModel(
        uid: 'u1',
        email: 'john@example.com',
        fullName: 'John Doe',
      ),
    );
    final biometricService = FakeBiometricService();

    await tester.pumpWidget(
      createTestWidget(
        prefs: prefs,
        authRepo: authRepo,
        biometricService: biometricService,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('تفضيلات التطبيق'), findsOneWidget);
    expect(find.text('الأمان'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('العملة'), findsOneWidget);
    expect(find.text('المصادقة الحيوية'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('3. Language dialog switches locale to ar and back to en', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository(
      user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
    );
    final biometricService = FakeBiometricService();

    await tester.pumpWidget(
      createTestWidget(
        prefs: prefs,
        authRepo: authRepo,
        biometricService: biometricService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.text('العربية'), findsOneWidget);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(prefs.getString('locale_code'), 'ar');
    expect(find.text('تفضيلات التطبيق'), findsOneWidget);

    await tester.tap(find.text('اللغة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(prefs.getString('locale_code'), 'en');
    expect(find.text('APP PREFERENCES'), findsOneWidget);
  });

  testWidgets('4. Appearance switch toggles theme mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository(
      user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
    );
    final biometricService = FakeBiometricService();

    await tester.pumpWidget(
      createTestWidget(
        prefs: prefs,
        authRepo: authRepo,
        biometricService: biometricService,
      ),
    );
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch).first;
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(prefs.getString('app_theme_mode'), 'dark');
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(prefs.getString('app_theme_mode'), 'light');
    expect(tester.widget<Switch>(switchFinder).value, isFalse);
  });

  testWidgets(
    '5. Currency tile shows code/symbol and opens CurrencySelectorDialog',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository(
        user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
      );
      final biometricService = FakeBiometricService();

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authRepo: authRepo,
          biometricService: biometricService,
          currency: 'USD',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('USD (\$)'), findsOneWidget);

      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencySelectorDialog), findsOneWidget);
    },
  );

  testWidgets(
    '9. Biometric switch stays off and shows snackbar on auth failure',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = FakeAuthRepository(
        user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
      );
      final biometricService = FakeBiometricService()
        ..shouldAuthenticate = false;

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          authRepo: authRepo,
          biometricService: biometricService,
        ),
      );
      await tester.pumpAndSettle();

      final bioSwitch = find.descendant(
        of: find.widgetWithText(ListTile, 'Biometric Authentication'),
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(bioSwitch).value, isFalse);

      await tester.ensureVisible(bioSwitch);
      await tester.tap(bioSwitch);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(bioSwitch).value, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Biometric authentication denied or cancelled.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('10. Logout dialog cancel vs confirm', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository(
      user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
    );
    final biometricService = FakeBiometricService();

    await tester.pumpWidget(
      createTestWidget(
        prefs: prefs,
        authRepo: authRepo,
        biometricService: biometricService,
      ),
    );
    await tester.pumpAndSettle();

    final logoutButton = find.widgetWithText(OutlinedButton, 'Log Out');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Log Out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(authRepo.signOutCount, 0);

    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Log Out'),
      ),
    );
    await tester.pumpAndSettle();

    expect(authRepo.signOutCount, 1);
  });

  testWidgets('11. Home screen no longer shows currency_exchange IconButton', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository(
      user: const UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B'),
    );
    final biometricService = FakeBiometricService();

    const dashboardState = DashboardState(
      incomeMinor: 5000,
      expenseMinor: 2000,
      currency: AppCurrency.usd,
      groupedTransactions: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          currentUserProvider.overrideWithValue(authRepo.currentUser),
          biometricServiceProvider.overrideWithValue(biometricService),
          currencyRepositoryProvider.overrideWithValue(
            FakeCurrencyRepository('USD'),
          ),
          appLockNotifierProvider.overrideWithValue(
            AppLockNotifier(initialLocked: false),
          ),
          dashboardControllerProvider.overrideWithValue(
            const AsyncValue.data(dashboardState),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.currency_exchange), findsNothing);
  });
}
