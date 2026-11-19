import 'package:fin_track_ai/domain/rates/per_usd_micros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I-21 value > 0 (rate 0 and negative rejected)', () {
    expect(() => PerUsdMicros(0), throwsArgumentError);
    expect(() => PerUsdMicros(-1), throwsArgumentError);

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
}
