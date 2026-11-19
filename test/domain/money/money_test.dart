import 'package:fin_track_ai/domain/money/currency_code.dart';
import 'package:fin_track_ai/domain/money/money.dart';
import 'package:fin_track_ai/domain/money/parse_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I-02 decimals never exceed currency precision', () {
    expect(CurrencyCode.ils.decimals, equals(2));
    expect(CurrencyCode.usd.decimals, equals(2));
    expect(CurrencyCode.jod.decimals, equals(3));

    expect(CurrencyCode.ils.minorFactor, equals(100));
    expect(CurrencyCode.usd.minorFactor, equals(100));
    expect(CurrencyCode.jod.minorFactor, equals(1000));
  });

  test('I-02 parse Money rejects extra decimals', () {
    expect(
      parseMoney('1.005', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.tooManyDecimals)),
    );
    expect(
      parseMoney('1.0005', CurrencyCode.jod),
      equals(const InvalidAmount(AmountError.tooManyDecimals)),
    );
  });

  test('I-02 parse Money rejects signs, grouping, exponent, NaN, and malformed strings', () {
    expect(
      parseMoney('-1.00', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.malformed)),
    );
    expect(
      parseMoney('+1.00', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.malformed)),
    );
    expect(
      parseMoney('1,000.00', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.malformed)),
    );
    expect(
      parseMoney('1e5', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.malformed)),
    );
    expect(
      parseMoney('NaN', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.malformed)),
    );
    expect(
      parseMoney('', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.empty)),
    );
  });

  test('K-01 parse Money and plain text round trip for each currency', () {
    expect(
      parseMoney('1.234', CurrencyCode.jod),
      equals(const ParsedMoney(Money(1234, CurrencyCode.jod))),
    );
    expect(const Money(1234, CurrencyCode.jod).toPlainText(), equals('1.234'));

    expect(
      parseMoney('10.50', CurrencyCode.ils),
      equals(const ParsedMoney(Money(1050, CurrencyCode.ils))),
    );
    expect(const Money(1050, CurrencyCode.ils).toPlainText(), equals('10.50'));

    expect(
      parseMoney('0.05', CurrencyCode.usd),
      equals(const ParsedMoney(Money(5, CurrencyCode.usd))),
    );
    expect(const Money(5, CurrencyCode.usd).toPlainText(), equals('0.05'));
  });

  test('K-01 maximum 10^12 minor units accepted, 10^12 + 1 rejected', () {
    expect(maxMinorUnits, equals(1000000000000));
    expect(
      parseMoney('10000000000.00', CurrencyCode.usd),
      equals(const ParsedMoney(Money(1000000000000, CurrencyCode.usd))),
    );
    expect(
      parseMoney('10000000000.01', CurrencyCode.usd),
      equals(const InvalidAmount(AmountError.aboveMaximum)),
    );
  });

  test('K-01 plus and minus with currency mismatch throws ArgumentError', () {
    const ilsMoney = Money(100, CurrencyCode.ils);
    const usdMoney = Money(100, CurrencyCode.usd);

    expect(() => ilsMoney.plus(usdMoney), throwsArgumentError);
    expect(() => ilsMoney.minus(usdMoney), throwsArgumentError);
  });

  test('K-01 CurrencyCode.fromIso returns corresponding enum or null', () {
    expect(CurrencyCode.fromIso('ILS'), equals(CurrencyCode.ils));
    expect(CurrencyCode.fromIso('USD'), equals(CurrencyCode.usd));
    expect(CurrencyCode.fromIso('JOD'), equals(CurrencyCode.jod));
    expect(CurrencyCode.fromIso('EUR'), isNull);
  });
}
