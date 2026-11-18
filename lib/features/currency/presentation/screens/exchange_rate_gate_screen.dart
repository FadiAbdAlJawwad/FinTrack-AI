import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/error/currency_exception.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../data/services/exchange_rate_service.dart';

/// Blocks the entire app when exchange rates cannot be loaded.
///
/// Rendered from [MaterialApp.router]'s `builder` so it takes over regardless
/// of the current route. The [error] parameter drives the displayed message:
///
/// - [NoExchangeRatesAvailableException] → "requires internet" copy + wifi-off
///   icon (device is offline and no stale cache exists).
/// - [ExchangeRateServiceException] → "service error" copy + cloud-off icon
///   (device has internet but the server returned an error or bad data).
class ExchangeRateGateScreen extends ConsumerWidget {
  const ExchangeRateGateScreen({super.key, required this.error});

  /// The exception that caused the gate to open. Must be either a
  /// [NoExchangeRatesAvailableException] or an [ExchangeRateServiceException].
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServiceError = error is ExchangeRateServiceException;

    final icon = isServiceError ? Icons.cloud_off : Icons.wifi_off;
    final message = isServiceError
        ? context.loc.exchangeRateServiceError
        : context.loc.internetRequiredFirstLaunch;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: ColorManager.secondaryColor),
              context.addVerticalSpace(16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.bodyMedium,
              ).padSymmetric(32),
              context.addVerticalSpace(24),
              ElevatedButton(
                onPressed: () => ref.invalidate(exchangeRatesBootstrapProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryBlue,
                ),
                child: Text(
                  context.loc.tryAgainButton,
                  style: context.labelLarge.copyWith(color: ColorManager.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
