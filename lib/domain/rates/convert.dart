import '../money/currency_code.dart';
import '../money/exact_amount.dart';
import '../money/money.dart';
import 'per_usd_micros.dart';

ExactAmount convert(
  Money amount, {
  required PerUsdMicros fromRate,
  required PerUsdMicros toRate,
  required CurrencyCode to,
}) => throw UnimplementedError();
