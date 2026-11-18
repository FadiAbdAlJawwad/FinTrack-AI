import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> extractPlaceholders(String message) {
  final placeholders = <String>{};
  int depth = 0;

  for (int i = 0; i < message.length; i++) {
    final char = message[i];
    if (char == '{') {
      if (depth == 0) {
        final rest = message.substring(i + 1);
        final match = RegExp(r'^\s*([a-zA-Z0-9_]+)').firstMatch(rest);
        if (match != null) {
          placeholders.add(match.group(1)!);
        }
      }
      depth++;
    } else if (char == '}') {
      if (depth > 0) {
        depth--;
      }
    }
  }

  return placeholders;
}

bool isPluralMessage(String message) {
  return RegExp(r'\{\s*\w+\s*,\s*plural\s*,').hasMatch(message);
}

List<String> checkArbParity(
  Map<String, dynamic> enMap,
  Map<String, dynamic> arMap,
) {
  final errors = <String>[];

  final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
  final arKeys = arMap.keys.where((k) => !k.startsWith('@')).toSet();

  // 1. Missing keys
  final missingInAr = enKeys.difference(arKeys);
  for (final key in (missingInAr.toList()..sort())) {
    errors.add('Missing key in ar: $key');
  }

  final missingInEn = arKeys.difference(enKeys);
  for (final key in (missingInEn.toList()..sort())) {
    errors.add('Missing key in en: $key');
  }

  // Common keys checks
  final commonKeys = enKeys.intersection(arKeys).toList()..sort();

  final requiredArabicPluralCategories = [
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other',
  ];

  for (final key in commonKeys) {
    final enVal = enMap[key];
    final arVal = arMap[key];

    if (enVal is! String || arVal is! String) continue;

    // 2. Placeholders check
    final enPlaceholders = extractPlaceholders(enVal);
    final arPlaceholders = extractPlaceholders(arVal);

    if (enPlaceholders.length != arPlaceholders.length ||
        !enPlaceholders.containsAll(arPlaceholders)) {
      final sortedEn = enPlaceholders.toList()..sort();
      final sortedAr = arPlaceholders.toList()..sort();
      errors.add(
        'Placeholder mismatch for key "$key": en=$sortedEn, ar=$sortedAr',
      );
    }

    // 3. Plurals check
    if (isPluralMessage(enVal)) {
      for (final cat in requiredArabicPluralCategories) {
        final catRegex = RegExp(r'\b' + cat + r'\s*\{');
        if (!catRegex.hasMatch(arVal)) {
          errors.add('Arabic plural for key "$key" missing category: $cat');
        }
      }
    }
  }

  return errors;
}

void main() {
  group('ARB Parity Checker Unit Tests (Inline Maps)', () {
    test('missing key fails', () {
      final en = {'key1': 'Hello', 'key2': 'World'};
      final ar = {'key1': 'مرحبا'};

      final errors = checkArbParity(en, ar);
      expect(errors, contains('Missing key in ar: key2'));
    });

    test('placeholder mismatch fails', () {
      final en = {'welcome': 'Hello {name}'};
      final ar = {'welcome': 'مرحبا {user}'};

      final errors = checkArbParity(en, ar);
      expect(
        errors,
        anyElement(contains('Placeholder mismatch for key "welcome"')),
      );
    });

    test('plural placeholder parsed and Arabic missing category fails', () {
      final en = {
        'itemCount':
            '{count, plural, =0{no items} one{1 item} other{{count} items}}',
      };
      final arPartial = {
        'itemCount': '{count, plural, zero{لا عناصر} one{عنصر واحد} other{{count} عناصر}}',
      };

      final errors = checkArbParity(en, arPartial);
      expect(
        errors,
        anyElement(
          contains('Arabic plural for key "itemCount" missing category: two'),
        ),
      );
      expect(
        errors,
        anyElement(
          contains('Arabic plural for key "itemCount" missing category: few'),
        ),
      );
      expect(
        errors,
        anyElement(
          contains('Arabic plural for key "itemCount" missing category: many'),
        ),
      );
    });

    test('valid parity passes', () {
      final en = {
        'greeting': 'Hello {name}',
        'itemCount': '{count, plural, one{1 item} other{{count} items}}',
      };
      final ar = {
        'greeting': 'مرحبا {name}',
        'itemCount': '{count, plural, zero{لا عناصر} one{عنصر واحد} two{عنصران} few{{count} عناصر} many{{count} عنصرًا} other{{count} عنصر}}',
      };

      final errors = checkArbParity(en, ar);
      expect(errors, isEmpty);
    });
  });

  group('ARB Parity Real Files Test', () {
    test('intl_en.arb and intl_ar.arb have full parity', () {
      final enFile = File('lib/l10n/intl_en.arb');
      final arFile = File('lib/l10n/intl_ar.arb');

      expect(
        enFile.existsSync(),
        isTrue,
        reason: 'lib/l10n/intl_en.arb must exist',
      );
      expect(
        arFile.existsSync(),
        isTrue,
        reason: 'lib/l10n/intl_ar.arb must exist',
      );

      final enMap =
          jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final arMap =
          jsonDecode(arFile.readAsStringSync()) as Map<String, dynamic>;

      final errors = checkArbParity(enMap, arMap);

      expect(
        errors,
        isEmpty,
        reason: 'ARB files parity errors:\n${errors.join('\n')}',
      );
    });
  });
}
