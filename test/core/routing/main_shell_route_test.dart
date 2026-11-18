import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';

import 'package:fin_track_ai/core/routing/main_shell_route.dart';
import 'package:fin_track_ai/core/routing/app_routes.dart';
import 'package:fin_track_ai/core/theme/app_theme.dart';
import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/features/shell/presentation/widgets/main_bottom_nav_bar.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestApp({
    Locale locale = const Locale('en'),
    Widget Function(BuildContext, GoRouterState)? homeBuilder,
  }) {
    final router = GoRouter(
      initialLocation: AppRoutes.homeScreen,
      routes: [
        buildMainShellRoute(
          homeBuilder:
              homeBuilder ??
              (context, state) => const Scaffold(body: Text('Home Content')),
        ),
        GoRoute(
          path: '/testDetails',
          builder: (context, state) =>
              const Scaffold(body: Text('Details View')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        currentUserProvider.overrideWithValue(null),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: AppTheme.lightTheme(locale.languageCode),
      ),
    );
  }

  testWidgets(
    '1. Initial state: four English labels are visible and Home is shown',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Wallets'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    },
  );

  testWidgets(
    '2. Tapping Analytics, Wallets, Settings shows each placeholder (its AppBar title)',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Analytics'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Wallets'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Wallets'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '3. State is preserved: increment Home counter, go to Wallets, return to Home',
    (WidgetTester tester) async {
      int counter = 0;
      await tester.pumpWidget(
        buildTestApp(
          homeBuilder: (context, state) => StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  Text('Counter: $counter'),
                  ElevatedButton(
                    onPressed: () => setState(() => counter++),
                    child: const Text('Increment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Counter: 0'), findsOneWidget);
      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Counter: 1'), findsOneWidget);

      await tester.tap(find.text('Wallets'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Wallets'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Counter: 1'), findsOneWidget);
    },
  );

  testWidgets(
    '4. Back from a non-Home tab returns to Home; a second back from Home pops',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );

      final dynamic widgetsBinding = tester.binding;
      bool didPop = await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(didPop, true);
      expect(find.text('Home Content'), findsOneWidget);

      didPop = await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(didPop, false); // Not handled, would exit app
    },
  );

  testWidgets(
    '5. A top-level route pushed from the shell is shown WITHOUT MainBottomNavBar',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          homeBuilder: (context, state) => Scaffold(
            body: ElevatedButton(
              onPressed: () => context.push('/testDetails'),
              child: const Text('Push Details'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainBottomNavBar), findsOneWidget);

      await tester.tap(find.text('Push Details'));
      await tester.pumpAndSettle();

      expect(find.text('Details View'), findsOneWidget);
      expect(find.byType(MainBottomNavBar), findsNothing);

      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MainBottomNavBar), findsOneWidget);
    },
  );

  testWidgets(
    '6. Arabic: with locale: Locale("ar") the four Arabic labels are shown',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('التحليلات'), findsOneWidget);
      expect(find.text('المحافظ'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
    },
  );

  testWidgets('7. The active tab is exposed via NavigationBar selectedIndex', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });

  testWidgets(
    '8. App builds with light and dark themes and labels are visible',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRoutes.homeScreen,
            routes: [
              buildMainShellRoute(
                homeBuilder: (context, state) =>
                    const Scaffold(body: Text('Home Content')),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: AppTheme.lightTheme('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRoutes.homeScreen,
            routes: [
              buildMainShellRoute(
                homeBuilder: (context, state) =>
                    const Scaffold(body: Text('Home Content')),
              ),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: AppTheme.darkTheme('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    },
  );

  test('9. Theme properties are correctly set for light and dark themes', () {
    final lightTheme = AppTheme.lightTheme('en');
    expect(
      lightTheme.navigationBarTheme.indicatorColor,
      ColorManager.primaryBlue,
    );
    expect(lightTheme.colorScheme.outlineVariant, ColorManager.lightBorder);

    final darkTheme = AppTheme.darkTheme('en');
    expect(
      darkTheme.navigationBarTheme.indicatorColor,
      ColorManager.primaryBlue,
    );
    expect(darkTheme.colorScheme.outlineVariant, ColorManager.darkBorder);
  });
}
