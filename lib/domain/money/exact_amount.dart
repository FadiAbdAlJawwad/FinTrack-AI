import 'currency_code.dart';
import 'money.dart';

/// An exact monetary amount represented as a rational fraction of minor units.
///
/// Throws [ArgumentError] if [denominator] is zero.
/// The fraction is reduced by GCD such that [denominator] is always > 0
/// (sign is carried by [numerator]), making field equality equal to value equality.
final class ExactAmount {
  factory ExactAmount(
    BigInt numerator,
    BigInt denominator,
    CurrencyCode currency,
  ) => throw UnimplementedError();

  factory ExactAmount.fromMoney(Money money) => throw UnimplementedError();

  // ignore: unused_element
  const ExactAmount._(this.numerator, this.denominator, this.currency);

  final BigInt numerator;
  final BigInt denominator;
  final CurrencyCode currency;

  ExactAmount plus(ExactAmount other) => throw UnimplementedError();
  Money roundToMinor() => throw UnimplementedError();

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}
