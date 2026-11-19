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
  ) {
    if (denominator == BigInt.zero) {
      throw ArgumentError('Denominator cannot be zero.');
    }
    var n = numerator;
    var den = denominator;
    if (den < BigInt.zero) {
      n = -n;
      den = -den;
    }
    final gcd = n.abs().gcd(den);
    n = n ~/ gcd;
    den = den ~/ gcd;
    return ExactAmount._(n, den, currency);
  }

  factory ExactAmount.fromMoney(Money money) {
    return ExactAmount(BigInt.from(money.minor), BigInt.one, money.currency);
  }

  const ExactAmount._(this.numerator, this.denominator, this.currency);

  final BigInt numerator;
  final BigInt denominator;
  final CurrencyCode currency;

  ExactAmount plus(ExactAmount other) {
    if (currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    final newNumerator =
        numerator * other.denominator + other.numerator * denominator;
    final newDenominator = denominator * other.denominator;
    return ExactAmount(newNumerator, newDenominator, currency);
  }

  Money roundToMinor() {
    final n = numerator;
    final den = denominator;
    final BigInt roundedMinor;

    if (n >= BigInt.zero) {
      final quotient = n ~/ den;
      final remainder = n % den;
      if (remainder * BigInt.from(2) >= den) {
        roundedMinor = quotient + BigInt.one;
      } else {
        roundedMinor = quotient;
      }
    } else {
      final absNum = n.abs();
      final quotient = absNum ~/ den;
      final remainder = absNum % den;
      if (remainder * BigInt.from(2) >= den) {
        roundedMinor = -(quotient + BigInt.one);
      } else {
        roundedMinor = -quotient;
      }
    }

    return Money(roundedMinor.toInt(), currency);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExactAmount &&
          runtimeType == other.runtimeType &&
          numerator == other.numerator &&
          denominator == other.denominator &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(numerator, denominator, currency);
}
