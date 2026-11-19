import 'currency_code.dart';

const int maxMinorUnits = 1000000000000;

final class Money {
  const Money(this.minor, this.currency)
    : assert(
        minor >= -maxMinorUnits && minor <= maxMinorUnits,
        'minor out of range',
      );

  final int minor;
  final CurrencyCode currency;

  Money plus(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return Money(minor + other.minor, currency);
  }

  Money minus(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return Money(minor - other.minor, currency);
  }

  String toPlainText() {
    final sign = minor < 0 ? '-' : '';
    final absolute = minor.abs();
    final whole = absolute ~/ currency.minorFactor;
    final fraction = (absolute % currency.minorFactor).toString().padLeft(
      currency.decimals,
      '0',
    );
    return '$sign$whole.$fraction';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          minor == other.minor &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(minor, currency);
}
