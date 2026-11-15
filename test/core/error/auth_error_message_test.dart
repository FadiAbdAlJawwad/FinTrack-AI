import 'package:fin_track_ai/core/error/auth_exception.dart';
import 'package:fin_track_ai/core/error/auth_exception_extension.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> pumpContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('AppAuthException maps to localized message', (tester) async {
    final context = await pumpContext(tester);
    final loc = AppLocalizations.of(context);
    final result = authErrorMessage(
      context,
      AppAuthException(AuthErrorType.wrongPassword),
    );
    expect(result, loc.wrongPassword);
  });

  testWidgets(
    'generic Exception maps to unknownError without leaking details',
    (tester) async {
      final context = await pumpContext(tester);
      final loc = AppLocalizations.of(context);
      final result = authErrorMessage(context, Exception('raw-detail-XYZ'));
      expect(result, loc.unknownError);
      expect(result.contains('raw-detail-XYZ'), false);
    },
  );

  testWidgets('StateError maps to unknownError', (tester) async {
    final context = await pumpContext(tester);
    final loc = AppLocalizations.of(context);
    final result = authErrorMessage(context, StateError('state error'));
    expect(result, loc.unknownError);
  });
}
