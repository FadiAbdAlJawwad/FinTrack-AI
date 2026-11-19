import 'package:fin_track_ai/domain/money/currency_code.dart';
import 'package:fin_track_ai/domain/money/money.dart';
import 'package:fin_track_ai/domain/rates/convert.dart';
import 'package:fin_track_ai/domain/rates/per_usd_micros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R-02b ILS->USD->ILS returns original within one minor unit for 1,000 sampled amounts', () {
    final ilsRate = PerUsdMicros(3712345);
    const usdRate = PerUsdMicros.usd;

    for (int i = 1; i <= 1000; i++) {
      final originalMinor = i * 123;
      final original = Money(originalMinor, CurrencyCode.ils);

      final exactUsd = convert(
        original,
        fromRate: ilsRate,
        toRate: usdRate,
        to: CurrencyCode.usd,
      );
      final usdMoney = exactUsd.roundToMinor();

      final exactIlsBack = convert(
        usdMoney,
        fromRate: usdRate,
        toRate: ilsRate,
        to: CurrencyCode.ils,
      );
      final ilsBack = exactIlsBack.roundToMinor();

      final diff = (ilsBack.minor - originalMinor).abs();
      expect(
        diff <= 1,
        isTrue,
        reason: 'Diff $diff > 1 for minor $originalMinor',
      );
    }
  });

  test('R-02b JOD (3 decimals) to ILS (2 decimals) exact fraction', () {
    const jodMoney = Money(1234, CurrencyCode.jod);
    final jodRate = PerUsdMicros(709000);
    final ilsRate = PerUsdMicros(3700000);

    final exact = convert(
      jodMoney,
      fromRate: jodRate,
      toRate: ilsRate,
      to: CurrencyCode.ils,
    );

    expect(exact.numerator, equals(BigInt.from(456580)));
    expect(exact.denominator, equals(BigInt.from(709)));
    expect(exact.currency, equals(CurrencyCode.ils));
  });

  test('R-02b same currency conversion returns amount unchanged', () {
    const original = Money(500, CurrencyCode.ils);
    final rate = PerUsdMicros(3700000);

    final exact = convert(
      original,
      fromRate: rate,
      toRate: rate,
      to: CurrencyCode.ils,
    );

    expect(exact.roundToMinor(), equals(original));
  });

  test(
    'ADR-0007 no overflow at 10^12 minor units with largest supported rate',
    () {
      const largeMoney = Money(1000000000000, CurrencyCode.usd);
      const usdRate = PerUsdMicros.usd;
      final maxRate = PerUsdMicros(10000000000000);

      final exact = convert(
        largeMoney,
        fromRate: usdRate,
        toRate: maxRate,
        to: CurrencyCode.ils,
      );

      expect(exact.numerator > BigInt.zero, isTrue);
    },
  );
}
