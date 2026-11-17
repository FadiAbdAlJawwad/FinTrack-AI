import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'shared_prefs_provider.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale_code';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final saved = prefs.getString(_key);
    if (saved != null) {
      final locale = Locale(saved);
      return AppLocalizations.delegate.isSupported(locale)
          ? locale
          : const Locale('en');
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_key, locale.languageCode);
  }
}
