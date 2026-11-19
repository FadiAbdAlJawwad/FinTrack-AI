const int maxPerUsdMicros = 1000000000000;

enum RateError {
  empty,
  malformed,
  nonPositive,

  /// integer part longer than 9 digits after leading zeros are removed
  tooManyIntegerDigits,

  /// rounded value is above maxPerUsdMicros (10^12)
  outOfRange,
}

sealed class RateParseResult {
  const RateParseResult();
}

final class ParsedRate extends RateParseResult {
  const ParsedRate(this.rate);

  final PerUsdMicros rate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedRate &&
          runtimeType == other.runtimeType &&
          rate == other.rate;

  @override
  int get hashCode => rate.hashCode;
}

final class InvalidRate extends RateParseResult {
  const InvalidRate(this.error);

  final RateError error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidRate &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

final class PerUsdMicros {
  /// Creates a validated exchange rate relative to 1 USD in micros.
  ///
  /// Throws [ArgumentError] if [value] is <= 0 or > [maxPerUsdMicros] (I-21).
  factory PerUsdMicros(int value) {
    if (value <= 0 || value > maxPerUsdMicros) {
      throw ArgumentError.value(
        value,
        'value',
        'PerUsdMicros must be positive (> 0) and <= maxPerUsdMicros ($maxPerUsdMicros)',
      );
    }
    return PerUsdMicros._(value);
  }

  static const PerUsdMicros usd = PerUsdMicros._(1000000);

  const PerUsdMicros._(this.value);

  final int value;

  static RateParseResult parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const InvalidRate(RateError.empty);
    }
    if (trimmed == '.') {
      return const InvalidRate(RateError.malformed);
    }

    if (trimmed.startsWith('-')) {
      final rest = trimmed.substring(1);
      final matchRest = RegExp(r'^(\d*)(?:\.(\d*))?$').firstMatch(rest);
      if (matchRest != null &&
          !(matchRest.group(1)!.isEmpty &&
              (matchRest.group(2) ?? '').isEmpty)) {
        return const InvalidRate(RateError.nonPositive);
      }
      return const InvalidRate(RateError.malformed);
    }

    if (trimmed.startsWith('+')) {
      return const InvalidRate(RateError.malformed);
    }

    final match = RegExp(r'^(\d*)(?:\.(\d*))?$').firstMatch(trimmed);
    if (match == null) {
      return const InvalidRate(RateError.malformed);
    }

    final whole = match.group(1)!;
    final fraction = match.group(2) ?? '';
    if (whole.isEmpty && fraction.isEmpty) {
      return const InvalidRate(RateError.empty);
    }

    final trimmedWhole = whole.replaceFirst(RegExp(r'^0+'), '');
    if (trimmedWhole.length > 9) {
      return const InvalidRate(RateError.tooManyIntegerDigits);
    }

    final wholeVal = trimmedWhole.isEmpty ? 0 : int.parse(trimmedWhole);
    int fracVal;

    if (fraction.length <= 6) {
      final padded = fraction.padRight(6, '0');
      fracVal = padded.isEmpty ? 0 : int.parse(padded);
    } else {
      final first6 = fraction.substring(0, 6);
      final digit7 = int.parse(fraction[6]);
      fracVal = int.parse(first6);
      if (digit7 >= 5) {
        fracVal += 1;
      }
    }

    final micros = wholeVal * 1000000 + fracVal;
    if (micros <= 0) {
      return const InvalidRate(RateError.nonPositive);
    }
    if (micros > maxPerUsdMicros) {
      return const InvalidRate(RateError.outOfRange);
    }

    return ParsedRate(PerUsdMicros(micros));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerUsdMicros &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
