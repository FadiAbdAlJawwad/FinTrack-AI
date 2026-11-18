import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:fin_track_ai/core/bootstrap/app_bootstrap.dart';
import 'package:fin_track_ai/core/bootstrap/boot_error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BootstrapApp Widget Tests', () {
    testWidgets(
      'bootstrap fails -> BootErrorScreen shown, appBuilder never invoked',
      (tester) async {
        bool appBuilderCalled = false;

        await tester.pumpWidget(
          BootstrapApp(
            bootstrap: () async => throw Exception('Init error'),
            appBuilder: (prefs) {
              appBuilderCalled = true;
              return const SizedBox();
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BootErrorScreen), findsOneWidget);
        expect(appBuilderCalled, isFalse);
      },
    );

    testWidgets('fails then retry succeeds -> appBuilder content shown', (
      tester,
    ) async {
      bool shouldFail = true;

      await tester.pumpWidget(
        BootstrapApp(
          bootstrap: () async {
            if (shouldFail) {
              throw Exception('Init error');
            }
            return await SharedPreferences.getInstance();
          },
          appBuilder: (prefs) =>
              const Text('App Content', textDirection: TextDirection.ltr),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BootErrorScreen), findsOneWidget);
      expect(find.text('App Content'), findsNothing);

      shouldFail = false;
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('App Content'), findsOneWidget);
      expect(find.byType(BootErrorScreen), findsNothing);
    });

    testWidgets(
      'during retry -> button disabled and progress indicator visible',
      (tester) async {
        final completer = Completer<SharedPreferences>();
        bool isFirstAttempt = true;

        await tester.pumpWidget(
          BootstrapApp(
            bootstrap: () {
              if (isFirstAttempt) {
                isFirstAttempt = false;
                throw Exception('First error');
              }
              return completer.future;
            },
            appBuilder: (prefs) => const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BootErrorScreen), findsOneWidget);

        // Tap retry button to initiate the second attempt
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Advance frame to reflect isRetrying state

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);

        completer.complete(await SharedPreferences.getInstance());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'widget disposed during pending bootstrap -> no setState error',
      (tester) async {
        final completer = Completer<SharedPreferences>();

        await tester.pumpWidget(
          BootstrapApp(
            bootstrap: () => completer.future,
            appBuilder: (prefs) => const SizedBox(),
          ),
        );
        await tester.pump();

        // Unmount the BootstrapApp while bootstrap is pending
        await tester.pumpWidget(const SizedBox());

        // Complete the pending bootstrap
        completer.complete(await SharedPreferences.getInstance());
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });

  group('runBootstrap Unit Tests', () {
    test('runBootstrap: initFirebase throws FirebaseException(code duplicate-app) -> succeeds', () async {
      final prefs = await runBootstrap(
        initFirebase: () async {
          throw FirebaseException(plugin: 'core', code: 'duplicate-app');
        },
        getPrefs: SharedPreferences.getInstance,
      );

      expect(prefs, isNotNull);
    });

    test(
      'runBootstrap: init never completes -> TimeoutException after timeout',
      () async {
        final completer = Completer<void>();

        expect(
          () => runBootstrap(
            initFirebase: () => completer.future,
            getPrefs: SharedPreferences.getInstance,
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );
      },
    );

    test('runBootstrap: getPrefs throws -> error propagates', () async {
      expect(
        () => runBootstrap(
          initFirebase: () async {},
          getPrefs: () async => throw Exception('Prefs error'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
