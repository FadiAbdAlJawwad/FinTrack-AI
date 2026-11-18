import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_track_ai/core/providers/router_provider.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // The real router/redirect chain requires Firebase platform channels,
    // which are unavailable in unit tests — inject a stub router through the
    // DI register instead of hitting FirebaseAuth/SharedPreferences singletons.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          goRouterProvider.overrideWithValue(
            GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Scaffold(),
                ),
              ],
            ),
          ),
        ],
        child: const FinTrackApp(),
      ),
    );

    // Basic check to see if the app loads
    expect(find.byType(FinTrackApp), findsOneWidget);
  });
}
