import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fin_track_ai/core/providers/locale_provider.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/core/services/biometric_service.dart';
import 'package:fin_track_ai/l10n/app_localizations_en.dart';

void main() {
  test('F-1 unsupported saved locale resolves to en', () async {
    SharedPreferences.setMockInitialValues({'locale_code': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(localeProvider), const Locale('en'));
    expect(
      container.read(biometricServiceProvider).localizedReason,
      AppLocalizationsEn().biometricReason,
    );
  });
}
