import 'currency_code.dart';
import 'money.dart';

enum AmountError { empty, malformed, tooManyDecimals, aboveMaximum }

sealed class ParseMoneyResult {
  const ParseMoneyResult();
}

final class ParsedMoney extends ParseMoneyResult {
  const ParsedMoney(this.money);

  final Money money;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedMoney &&
          runtimeType == other.runtimeType &&
          money == other.money;

  @override
  int get hashCode => money.hashCode;
}

final class InvalidAmount extends ParseMoneyResult {
  const InvalidAmount(this.error);

  final AmountError error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidAmount &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

final RegExp _amountPattern = RegExp(r'^(\d*)(?:\.(\d*))?$');

ParseMoneyResult parseMoney(String text, CurrencyCode currency) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return const InvalidAmount(AmountError.empty);
  }

  final match = _amountPattern.firstMatch(trimmed);
  if (match == null) {
    return const InvalidAmount(AmountError.malformed);
  }

  final whole = match.group(1)!;
  final fraction = match.group(2) ?? '';
  if (whole.isEmpty && fraction.isEmpty) {
    return const InvalidAmount(AmountError.empty);
  }

  if (fraction.length > currency.decimals) {
    return const InvalidAmount(AmountError.tooManyDecimals);
  }

  final trimmedWhole = whole.replaceFirst(RegExp(r'^0+'), '');
  if (trimmedWhole.length > 13) {
    return const InvalidAmount(AmountError.aboveMaximum);
  }

  final wholeValue = trimmedWhole.isEmpty ? 0 : int.parse(trimmedWhole);
  final fractionPadded = fraction.padRight(currency.decimals, '0');
  final fractionValue = fractionPadded.isEmpty ? 0 : int.parse(fractionPadded);
  final minor = wholeValue * currency.minorFactor + fractionValue;

  if (minor > maxMinorUnits) {
    return const InvalidAmount(AmountError.aboveMaximum);
  }

  return ParsedMoney(Money(minor, currency));
}
