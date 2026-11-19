import 'package:fin_track_ai/domain/time/clock.dart';
import 'package:fin_track_ai/domain/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements Clock {
  const FakeClock(this.today);

  final LocalDate today;

  @override
  LocalDate localToday() => today;
}

void main() {
  test('B-01 LocalDate invariant: invalid dates rejected (2026-02-30)', () {
    expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
    expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
    expect(() => LocalDate(2026, 0, 1), throwsArgumentError);
    expect(() => LocalDate(2026, 1, 0), throwsArgumentError);

    expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
    expect(LocalDate.tryParse('2026-02-30'), isNull);
  });

  test('B-01 LocalDate invariant: LocalDate(2026,2,29) and LocalDate(2026,13,1) throw ArgumentError; LocalDate(2028,2,29) is valid', () {
    expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
    expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
    expect(LocalDate(2028, 2, 29), isNotNull);
  });

  test('B-01 LocalDate invariant: ordering and compareTo', () {
    final d1 = LocalDate(2026, 2, 1);
    final d2 = LocalDate(2026, 2, 2);

    expect(d1.compareTo(d2), lessThan(0));
    expect(d2.compareTo(d1), greaterThan(0));
    expect(d1.compareTo(d1), equals(0));
    expect(d2.isAfter(d1), isTrue);
    expect(d1.isAfter(d2), isFalse);
  });

  test('B-01 LocalDate invariant: ISO 8601 text round trip', () {
    final date = LocalDate(2026, 11, 18);
    expect(date.toIso8601String(), equals('2026-11-18'));
    expect(LocalDate.parse('2026-11-18'), equals(date));
  });

  test('B-01 Clock invariant: fake returns fixed local date', () {
    final fixedDate = LocalDate(2026, 11, 18);
    final Clock clock = FakeClock(fixedDate);

    expect(clock.localToday(), equals(fixedDate));
  });

  test('B-01 LocalDate invariant: year range 1..9999', () {
    expect(() => LocalDate(0, 1, 1), throwsArgumentError);
    expect(() => LocalDate(10000, 1, 1), throwsArgumentError);
    expect(LocalDate(1, 1, 1), isNotNull);
    expect(LocalDate(9999, 12, 31), isNotNull);
  });
}
