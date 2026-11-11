import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/domain/usecases/money.dart';
import '../../../transactions/domain/models/transaction_model.dart';

/// Checks if a wallet has sufficient balance for a transaction.
///
/// Rules:
/// - Income transactions always return true.
/// - If [walletHasHistory] is false, return true.
/// - If [walletBalanceMinor] is null, return true.
/// - Converts [amountMinor] to [baseCurrency] using [rateBetween]. If conversion throws, return true.
/// - available = [walletBalanceMinor] + ([replacedAmountMinorInBase] ?? 0).
/// - Returns true if available - convertedAmount >= 0.
bool hasSufficientBalance({
  required int? walletBalanceMinor,
  required AppCurrency baseCurrency,
  required int amountMinor,
  required AppCurrency amountCurrency,
  required TransactionType type,
  int? replacedAmountMinorInBase,
  required double Function(AppCurrency from, AppCurrency to) rateBetween,
  bool walletHasHistory = true,
}) {
  if (type == TransactionType.income) return true;
  if (!walletHasHistory) return true;
  if (walletBalanceMinor == null) return true;

  int convertedAmount;
  if (amountCurrency == baseCurrency) {
    convertedAmount = amountMinor;
  } else {
    try {
      final rate = rateBetween(amountCurrency, baseCurrency);
      convertedAmount = convertMinorUnits(
        amountMinor,
        amountCurrency,
        baseCurrency,
        rate,
      );
    } catch (_) {
      return true;
    }
  }

  final available = walletBalanceMinor + (replacedAmountMinorInBase ?? 0);
  return available - convertedAmount >= 0;
}
