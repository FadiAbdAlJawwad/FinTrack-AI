import 'package:fin_track_ai/domain/money/currency_code.dart';
import 'package:fin_track_ai/domain/money/money.dart';
import 'package:fin_track_ai/domain/rates/convert.dart';
import 'package:fin_track_ai/domain/rates/per_usd_micros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R-02b USD->ILS->USD returns the original exactly for 1,000 sampled amounts', () {
    final ilsRate = PerUsdMicros(3712345);
    const usdRate = PerUsdMicros.usd;

    for (var i = 1; i <= 1000; i++) {
      final originalMinor = i * 123;
      final original = Money(originalMinor, CurrencyCode.usd);

      final ils = convert(
        original,
        fromRate: usdRate,
        toRate: ilsRate,
        to: CurrencyCode.ils,
      ).roundToMinor();
      final back = convert(
        ils,
        fromRate: ilsRate,
        toRate: usdRate,
        to: CurrencyCode.usd,
      ).roundToMinor();

      expect(back.minor, originalMinor, reason: 'minor $originalMinor');
    }
  });

  test('R-02b ILS->USD->ILS stays within the two-rounding bound for 1,000 sampled amounts', () {
    final ilsRate = PerUsdMicros(3712345);
    const usdRate = PerUsdMicros.usd;
    // Two half-up roundings: 0.5 USD cent x 3.712345 + 0.5 ILS cent = 2.36,
    // so the round trip may differ by at most 2 ILS minor units.
    const bound = 2;

    for (var i = 1; i <= 1000; i++) {
      final originalMinor = i * 123;
      final original = Money(originalMinor, CurrencyCode.ils);

      final usd = convert(
        original,
        fromRate: ilsRate,
        toRate: usdRate,
        to: CurrencyCode.usd,
      ).roundToMinor();
      final back = convert(
        usd,
        fromRate: usdRate,
        toRate: ilsRate,
        to: CurrencyCode.ils,
      ).roundToMinor();

      final diff = (back.minor - originalMinor).abs();
      expect(
        diff <= bound,
        isTrue,
        reason: 'Diff $diff > $bound for minor $originalMinor',
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
