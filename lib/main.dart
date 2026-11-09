import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/constant/app_env.dart';
import 'core/constant/shared_prefs_keys.dart';
import 'core/error/currency_exception.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/router_provider.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_lock_notifier.dart';
import 'core/routing/app_lock_lifecycle_observer.dart';
import 'features/currency/data/services/exchange_rate_service.dart';
import 'features/currency/presentation/screens/exchange_rate_gate_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    BootstrapApp(
      bootstrap: runBootstrap,
      appBuilder: (prefs) {
        if (!AppEnv.isAiConfigured) {
          if (kDebugMode) {
            debugPrint(
              'Warning: AI config is missing or invalid. Voice entry will be disabled.',
            );
          }
        }
        
        final isBiometricEnabled = prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey) ?? false;
        final isUserSignedIn = FirebaseAuth.instance.currentUser != null;
        final appLockNotifier = AppLockNotifier(
          initialLocked: isBiometricEnabled && isUserSignedIn,
        );
        
        return ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            appLockNotifierProvider.overrideWithValue(appLockNotifier),
          ],
          child: AppLockLifecycleObserver(
            appLockNotifier: appLockNotifier,
            firebaseAuth: FirebaseAuth.instance,
            prefs: prefs,
            child: const FinTrackApp(),
          ),
        );
      },
    ),
  );
}

class FinTrackApp extends ConsumerWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final goRouter = ref.watch(goRouterProvider);
    final ratesBootstrap = ref.watch(exchangeRatesBootstrapProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.lightTheme(locale.languageCode),
      darkTheme: AppTheme.darkTheme(locale.languageCode),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final error = ratesBootstrap.error;
        if (error != null) {
          return ExchangeRateGateScreen(
            error: (error is NoExchangeRatesAvailableException ||
                    error is ExchangeRateServiceException)
                ? error
                : ExchangeRateServiceException(error.toString()),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
