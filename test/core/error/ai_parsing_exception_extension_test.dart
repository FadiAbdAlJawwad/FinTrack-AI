import 'package:fin_track_ai/core/error/ai_parsing_exception.dart';
import 'package:fin_track_ai/core/error/ai_parsing_exception_extension.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> pumpContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
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
  testWidgets('AiParsingErrorType mapping matches localized strings', (
    tester,
  ) async {
    final context = await pumpContext(tester);
    final loc = AppLocalizations.of(context);
    final expected = {
      AiParsingErrorType.notConfigured: loc.aiNotConfigured,
      AiParsingErrorType.unauthorized: loc.aiUnauthorized,
      AiParsingErrorType.invalidInput: loc.aiInvalidInput,
      AiParsingErrorType.serviceUnavailable: loc.aiServiceUnavailable,
      AiParsingErrorType.schemaValidationFailed: loc.aiSchemaValidationFailed,
      AiParsingErrorType.networkError: loc.aiNetworkError,
      AiParsingErrorType.unknown: loc.aiUnknown,
    };

    expect(expected.keys.toSet(), AiParsingErrorType.values.toSet());
    for (final entry in expected.entries) {
      expect(
        AiParsingException(entry.key).getLocalizedMessage(context),
        entry.value,
      );
    }
  });

  testWidgets('notConfigured message differs from networkError message', (
    tester,
  ) async {
    final context = await pumpContext(tester);

    final notConfiguredMsg = AiParsingException(
      AiParsingErrorType.notConfigured,
    ).getLocalizedMessage(context);
    final networkErrorMsg = AiParsingException(AiParsingErrorType.networkError)
        .getLocalizedMessage(context);

    expect(notConfiguredMsg, isNot(equals(networkErrorMsg)));
  });
}
