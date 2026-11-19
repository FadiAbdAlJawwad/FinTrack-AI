enum RateError { empty, malformed, nonPositive, tooManyIntegerDigits }

sealed class RateParseResult {
  const RateParseResult();
}

final class ParsedRate extends RateParseResult {
  const ParsedRate(this.rate);

  final PerUsdMicros rate;

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}

final class InvalidRate extends RateParseResult {
  const InvalidRate(this.error);

  final RateError error;

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}

final class PerUsdMicros {
  /// Creates a validated exchange rate relative to 1 USD in micros.
  ///
  /// Throws [ArgumentError] if [value] is <= 0 (I-21).
  factory PerUsdMicros(int value) => throw UnimplementedError();

  static const PerUsdMicros usd = PerUsdMicros._(1000000);

  const PerUsdMicros._(this.value);

  final int value;

  static RateParseResult parse(String text) => throw UnimplementedError();

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}
