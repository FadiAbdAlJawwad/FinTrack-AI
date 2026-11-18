import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../l10n/app_localizations.dart';
import '../constant/color_manager.dart';
import '../extension/app_sizes.dart';
import '../extension/text_style_extension.dart';
import '../theme/app_theme.dart';

/// English-only error screen shown when app bootstrap fails.
///
/// Builds its own self-contained [MaterialApp] without Riverpod or GoRouter.
/// Removes the native splash screen on first display and allows retrying initialization.
class BootErrorScreen extends StatelessWidget {
  const BootErrorScreen({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme('en'),
      darkTheme: AppTheme.darkTheme('en'),
      themeMode: ThemeMode.system,
      home: _BootErrorContent(onRetry: onRetry, isRetrying: isRetrying),
    );
  }
}

class _BootErrorContent extends StatefulWidget {
  const _BootErrorContent({required this.onRetry, required this.isRetrying});

  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  State<_BootErrorContent> createState() => _BootErrorContentState();
}

class _BootErrorContentState extends State<_BootErrorContent> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: ColorManager.errorColor,
              ),
              context.addVerticalSpace(16),
              Text(
                context.loc.bootErrorTitle,
                textAlign: TextAlign.center,
                style: context.headlineMedium,
              ).padSymmetric(32),
              context.addVerticalSpace(8),
              Text(
                context.loc.bootErrorMessage,
                textAlign: TextAlign.center,
                style: context.bodyMedium,
              ).padSymmetric(32),
              context.addVerticalSpace(24),
              ElevatedButton(
                onPressed: widget.isRetrying ? null : widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryBlue,
                ),
                child: widget.isRetrying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorManager.white,
                        ),
                      )
                    : Text(
                        context.loc.tryAgainButton,
                        style: context.labelLarge.copyWith(
                          color: ColorManager.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
