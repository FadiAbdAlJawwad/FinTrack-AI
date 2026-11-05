import 'package:flutter/widgets.dart';

import '../../../../core/error/currency_exception.dart';
import '../../../../core/error/currency_write_exception.dart';
import '../../../../core/error/transaction_exception.dart';
import '../../../../core/error/wallet_exception.dart';
import '../../../../core/extension/app_sizes.dart';

/// Maps a domain error to a localized, user-safe message.
///
/// Never exposes `error.toString()` or SDK messages to the user.
String errorMessage(BuildContext context, Object error) {
  final loc = context.loc;
  if (error is CurrencyException) {
    switch (error.type) {
      case CurrencyErrorType.networkError:
        return loc.networkRequestFailed;
      case CurrencyErrorType.permissionDenied:
        return loc.databaseError;
      case CurrencyErrorType.notAuthenticated:
        return loc.sessionExpired;
      case CurrencyErrorType.unknown:
        return loc.unknownError;
    }
  }
  if (error is TransactionException) {
    switch (error.type) {
      case TransactionErrorType.networkError:
        return loc.networkRequestFailed;
      case TransactionErrorType.permissionDenied:
      case TransactionErrorType.notFound:
      case TransactionErrorType.invalidData:
        return loc.databaseError;
      case TransactionErrorType.notAuthenticated:
        return loc.sessionExpired;
      case TransactionErrorType.unknown:
        return loc.unknownError;
    }
  }
  if (error is WalletException) {
    switch (error.type) {
      case WalletErrorType.networkError:
        return loc.networkRequestFailed;
      case WalletErrorType.permissionDenied:
      case WalletErrorType.notFound:
      case WalletErrorType.invalidData:
        return loc.databaseError;
      case WalletErrorType.notAuthenticated:
        return loc.sessionExpired;
      case WalletErrorType.unknown:
        return loc.unknownError;
    }
  }
  if (error is NoExchangeRatesAvailableException ||
      error is ExchangeRateServiceException) {
    return loc.exchangeRateServiceError;
  }
  return loc.unknownError;
}
