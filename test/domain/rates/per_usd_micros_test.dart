import 'package:fin_track_ai/domain/rates/per_usd_micros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I-21 value > 0 and <= maxPerUsdMicros (rate 0, negative, and > maxPerUsdMicros rejected)', () {
    expect(() => PerUsdMicros(0), throwsArgumentError);
    expect(() => PerUsdMicros(-1), throwsArgumentError);
    expect(PerUsdMicros(maxPerUsdMicros).value, equals(maxPerUsdMicros));
    expect(() => PerUsdMicros(maxPerUsdMicros + 1), throwsArgumentError);

    expect(
      PerUsdMicros.parse('0'),
      equals(const InvalidRate(RateError.nonPositive)),
    );
    expect(
      PerUsdMicros.parse('-1.5'),
      equals(const InvalidRate(RateError.nonPositive)),
    );
  });

  test(
    'ADR-0007 text parse half-up at 7th decimal ("3.7123455" -> 3712346)',
    () {
      expect(
        PerUsdMicros.parse('3.7123455'),
        equals(ParsedRate(PerUsdMicros(3712346))),
      );
      expect(
        PerUsdMicros.parse('3.7123454'),
        equals(ParsedRate(PerUsdMicros(3712345))),
      );
      expect(
        PerUsdMicros.parse('1.000000'),
        equals(ParsedRate(PerUsdMicros(1000000))),
      );
    },
  );

  test('ADR-0007 text with more than 13 integer digits rejected', () {
    expect(
      PerUsdMicros.parse('12345678901234.0'),
      equals(const InvalidRate(RateError.tooManyIntegerDigits)),
    );
  });

  test('ADR-0007 no floating point precision loss (parse of "0.1", "0.2", "0.3" exact)', () {
    expect(PerUsdMicros.parse('0.1'), equals(ParsedRate(PerUsdMicros(100000))));
    expect(PerUsdMicros.parse('0.2'), equals(ParsedRate(PerUsdMicros(200000))));
    expect(PerUsdMicros.parse('0.3'), equals(ParsedRate(PerUsdMicros(300000))));
  });

  test('ADR-0007 parse "1000000" returns maxPerUsdMicros', () {
    expect(
      PerUsdMicros.parse('1000000'),
      equals(ParsedRate(PerUsdMicros(1000000000000))),
    );
  });

  test('ADR-0007 parse "999999.9999995" rounds up to maxPerUsdMicros', () {
    expect(
      PerUsdMicros.parse('999999.9999995'),
      equals(ParsedRate(PerUsdMicros(1000000000000))),
    );
  });

  test('ADR-0007 parse "1000000.0000005" rounds up above maxPerUsdMicros (outOfRange)', () {
    expect(
      PerUsdMicros.parse('1000000.0000005'),
      equals(const InvalidRate(RateError.outOfRange)),
    );
  });

  test('ADR-0007 parse "1000000.000001" returns outOfRange', () {
    expect(
      PerUsdMicros.parse('1000000.000001'),
      equals(const InvalidRate(RateError.outOfRange)),
    );
  });

  test('ADR-0007 parse "999999999" returns outOfRange', () {
    expect(
      PerUsdMicros.parse('999999999'),
      equals(const InvalidRate(RateError.outOfRange)),
    );
  });

  test('ADR-0007 parse "1234567890" returns tooManyIntegerDigits', () {
    expect(
      PerUsdMicros.parse('1234567890'),
      equals(const InvalidRate(RateError.tooManyIntegerDigits)),
    );
  });

  test('ADR-0007 parse "0000000001" with leading zeros returns 1000000', () {
    expect(
      PerUsdMicros.parse('0000000001'),
      equals(ParsedRate(PerUsdMicros(1000000))),
    );
  });

  test('ADR-0007 parse "0.0000005" rounds up to 1', () {
    expect(
      PerUsdMicros.parse('0.0000005'),
      equals(ParsedRate(PerUsdMicros(1))),
    );
  });

  test('ADR-0007 parse "0.00000049999" rounds down to 0 (nonPositive)', () {
    expect(
      PerUsdMicros.parse('0.00000049999'),
      equals(const InvalidRate(RateError.nonPositive)),
    );
  });

  test('ADR-0007 parse "0.0000004" rounds down to 0 (nonPositive)', () {
    expect(
      PerUsdMicros.parse('0.0000004'),
      equals(const InvalidRate(RateError.nonPositive)),
    );
  });

  test('ADR-0007 parse "1.0000004999" rounds down to 1000000', () {
    expect(
      PerUsdMicros.parse('1.0000004999'),
      equals(ParsedRate(PerUsdMicros(1000000))),
    );
  });

  test('ADR-0007 PerUsdMicros.parse rejects single dot as malformed', () {
    expect(
      PerUsdMicros.parse('.'),
      equals(const InvalidRate(RateError.malformed)),
    );
  });
}
