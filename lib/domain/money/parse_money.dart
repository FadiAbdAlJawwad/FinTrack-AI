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
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}

final class InvalidAmount extends ParseMoneyResult {
  const InvalidAmount(this.error);

  final AmountError error;

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}

ParseMoneyResult parseMoney(String text, CurrencyCode currency) =>
    throw UnimplementedError();
