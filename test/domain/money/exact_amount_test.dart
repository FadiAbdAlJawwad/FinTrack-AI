import 'package:fin_track_ai/domain/money/currency_code.dart';
import 'package:fin_track_ai/domain/money/exact_amount.dart';
import 'package:fin_track_ai/domain/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BR-15 half-up rounding at .5 rounds half away from zero', () {
    final positiveHalf = ExactAmount(
      BigInt.from(5),
      BigInt.from(2),
      CurrencyCode.ils,
    );
    expect(
      positiveHalf.roundToMinor(),
      equals(const Money(3, CurrencyCode.ils)),
    );

    final negativeHalf = ExactAmount(
      BigInt.from(-5),
      BigInt.from(2),
      CurrencyCode.ils,
    );
    expect(
      negativeHalf.roundToMinor(),
      equals(const Money(-3, CurrencyCode.ils)),
    );

    final positiveBelowHalf = ExactAmount(
      BigInt.from(12),
      BigInt.from(5),
      CurrencyCode.ils,
    );
    expect(
      positiveBelowHalf.roundToMinor(),
      equals(const Money(2, CurrencyCode.ils)),
    );

    final negativeBelowHalf = ExactAmount(
      BigInt.from(-12),
      BigInt.from(5),
      CurrencyCode.ils,
    );
    expect(
      negativeBelowHalf.roundToMinor(),
      equals(const Money(-2, CurrencyCode.ils)),
    );

    final positiveAboveHalf = ExactAmount(
      BigInt.from(13),
      BigInt.from(5),
      CurrencyCode.ils,
    );
    expect(
      positiveAboveHalf.roundToMinor(),
      equals(const Money(3, CurrencyCode.ils)),
    );

    final negativeAboveHalf = ExactAmount(
      BigInt.from(-13),
      BigInt.from(5),
      CurrencyCode.ils,
    );
    expect(
      negativeAboveHalf.roundToMinor(),
      equals(const Money(-3, CurrencyCode.ils)),
    );
  });

  test('NFR-07 sum of 1,000 ExactAmount values equals single fraction computed directly', () {
    ExactAmount sum = ExactAmount(BigInt.zero, BigInt.one, CurrencyCode.ils);
    BigInt expectedNumeratorSum = BigInt.zero;

    for (int i = 1; i <= 1000; i++) {
      final amount = ExactAmount(
        BigInt.from(i),
        BigInt.from(7),
        CurrencyCode.ils,
      );
      sum = sum.plus(amount);
      expectedNumeratorSum += BigInt.from(i);
    }

    final expectedDirect = ExactAmount(
      expectedNumeratorSum,
      BigInt.from(7),
      CurrencyCode.ils,
    );
    expect(sum, equals(expectedDirect));
  });

  test('NFR-07 gcd reduction keeps exact fraction value', () {
    final unreduced = ExactAmount(
      BigInt.from(200),
      BigInt.from(400),
      CurrencyCode.usd,
    );
    expect(unreduced.numerator, equals(BigInt.one));
    expect(unreduced.denominator, equals(BigInt.from(2)));
  });

  test('BR-15 plus with currency mismatch throws ArgumentError', () {
    final ilsAmount = ExactAmount(
      BigInt.from(100),
      BigInt.one,
      CurrencyCode.ils,
    );
    final usdAmount = ExactAmount(
      BigInt.from(100),
      BigInt.one,
      CurrencyCode.usd,
    );

    expect(() => ilsAmount.plus(usdAmount), throwsArgumentError);
  });

  test('B-01 ExactAmount invariant: denominator 0 throws ArgumentError', () {
    expect(
      () => ExactAmount(BigInt.one, BigInt.zero, CurrencyCode.ils),
      throwsArgumentError,
    );
  });

  test(
    'B-01 ExactAmount invariant: ExactAmount(2,4,c) == ExactAmount(1,2,c)',
    () {
      expect(
        ExactAmount(BigInt.from(2), BigInt.from(4), CurrencyCode.usd),
        equals(ExactAmount(BigInt.one, BigInt.from(2), CurrencyCode.usd)),
      );
    },
  );

  test('B-01 ExactAmount invariant: ExactAmount(1,-2,c) has numerator -1 and denominator 2', () {
    final amount = ExactAmount(BigInt.one, BigInt.from(-2), CurrencyCode.usd);
    expect(amount.numerator, equals(BigInt.from(-1)));
    expect(amount.denominator, equals(BigInt.from(2)));
  });
}
