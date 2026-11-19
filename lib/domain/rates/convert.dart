import '../money/currency_code.dart';
import '../money/exact_amount.dart';
import '../money/money.dart';
import 'per_usd_micros.dart';

ExactAmount convert(
  Money amount, {
  required PerUsdMicros fromRate,
  required PerUsdMicros toRate,
  required CurrencyCode to,
}) {
  if (amount.currency == to) {
    return ExactAmount.fromMoney(amount);
  }
  final numerator =
      BigInt.from(amount.minor) *
      BigInt.from(toRate.value) *
      BigInt.from(to.minorFactor);
  final denominator =
      BigInt.from(fromRate.value) * BigInt.from(amount.currency.minorFactor);

  return ExactAmount(numerator, denominator, to);
}
