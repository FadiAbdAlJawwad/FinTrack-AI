import 'currency_code.dart';

const int maxMinorUnits = 1000000000000;

final class Money {
  const Money(this.minor, this.currency);

  final int minor;
  final CurrencyCode currency;

  Money plus(Money other) => throw UnimplementedError();
  Money minus(Money other) => throw UnimplementedError();
  String toPlainText() => throw UnimplementedError();

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}
