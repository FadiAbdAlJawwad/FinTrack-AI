import 'package:fin_track_ai/features/analytics/domain/models/analytics_period.dart';
import 'package:fin_track_ai/features/analytics/domain/usecases/analytics_period_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('analyticsPeriodRange', () {
    test('1. week, now = 2026-10-14 15:30 -> start 2026-10-08 00:00, endExclusive 2026-10-15 00:00', () {
      final now = DateTime(2026, 10, 14, 15, 30);
      final range = analyticsPeriodRange(AnalyticsPeriod.week, now);
      expect(range.start, DateTime(2026, 10, 8, 0, 0));
      expect(range.endExclusive, DateTime(2026, 10, 15, 0, 0));
    });

    test(
      '2. week crossing a month boundary, now = 2026-03-03 -> start 2026-02-25',
      () {
        final now = DateTime(2026, 3, 3);
        final range = analyticsPeriodRange(AnalyticsPeriod.week, now);
        expect(range.start, DateTime(2026, 2, 25));
        expect(range.endExclusive, DateTime(2026, 3, 4));
      },
    );

    test('3. month, now = 2026-10-14 -> 2026-10-01 .. 2026-11-01', () {
      final now = DateTime(2026, 10, 14);
      final range = analyticsPeriodRange(AnalyticsPeriod.month, now);
      expect(range.start, DateTime(2026, 10, 1));
      expect(range.endExclusive, DateTime(2026, 11, 1));
    });

    test(
      '4. month in December, now = 2026-12-20 -> endExclusive 2027-01-01',
      () {
        final now = DateTime(2026, 12, 20);
        final range = analyticsPeriodRange(AnalyticsPeriod.month, now);
        expect(range.start, DateTime(2026, 12, 1));
        expect(range.endExclusive, DateTime(2027, 1, 1));
      },
    );

    test('5. year (12 months), now = 2026-10-14 -> start 2025-11-01, endExclusive 2026-11-01', () {
      final now = DateTime(2026, 10, 14);
      final range = analyticsPeriodRange(AnalyticsPeriod.year, now);
      expect(range.start, DateTime(2025, 11, 1));
      expect(range.endExclusive, DateTime(2026, 11, 1));
    });

    test(
      '6. year across a year boundary, now = 2026-01-15 -> start 2025-02-01',
      () {
        final now = DateTime(2026, 1, 15);
        final range = analyticsPeriodRange(AnalyticsPeriod.year, now);
        expect(range.start, DateTime(2025, 2, 1));
        expect(range.endExclusive, DateTime(2026, 2, 1));
      },
    );
  });
}
