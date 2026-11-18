import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../currency/presentation/widgets/currency_selector_dialog.dart';
import 'language_selector_dialog.dart';
import 'settings_section.dart';

class AppPreferencesSection extends ConsumerWidget {
  const AppPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final languageName = currentLocale.languageCode == 'ar'
        ? 'العربية'
        : 'English';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currencyCode =
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD';
    final appCurrency = appCurrencyFromCode(currencyCode);
    final currencyDisplay = '${appCurrency.code} (${appCurrency.symbol})';

    return SettingsSection(
      title: context.loc.settingsPreferences,
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(context.loc.settingsLanguage),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(languageName, style: context.bodyMedium),
              context.addHorizontalSpace(4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const LanguageSelectorDialog(),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: Text(context.loc.settingsAppearance),
          subtitle: Text(
            isDark
                ? context.loc.settingsThemeDark
                : context.loc.settingsThemeLight,
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text(context.loc.settingsCurrency),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currencyDisplay, style: context.bodyMedium),
              context.addHorizontalSpace(4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const CurrencySelectorDialog(),
            );
          },
        ),
      ],
    );
  }
}
