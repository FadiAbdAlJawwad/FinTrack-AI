import 'package:fin_track_ai/core/error/currency_exception.dart';
import 'package:fin_track_ai/features/analytics/domain/models/analytics_period.dart';
import 'package:fin_track_ai/features/analytics/domain/usecases/build_analytics_summary_usecase.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel makeTx({
  required String id,
  required int amountMinor,
  required AppCurrency currency,
  required TransactionType type,
  required TransactionCategory category,
  required DateTime date,
}) {
  return TransactionModel(
    id: id,
    amountMinor: amountMinor,
    currency: currency,
    type: type,
    category: category,
    title: 'Test',
    date: date,
    walletId: 'w1',
  );
}

double noRate(AppCurrency from, AppCurrency to) =>
    throw NoExchangeRatesAvailableException();

void main() {
  final now = DateTime(2026, 10, 14, 12, 0); // Month: 2026-10-01 to 2026-11-01

  group('buildAnalyticsSummary', () {
    test('7. A transaction exactly at start is included; one exactly at endExclusive is excluded; one second before start is excluded', () {
      final start = DateTime(2026, 10, 1);
      final endExclusive = DateTime(2026, 11, 1);
      final beforeStart = start.subtract(const Duration(seconds: 1));

      final transactions = [
        makeTx(
          id: 'txAtStart',
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: start,
        ),
        makeTx(
          id: 'txAtEndExclusive',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: endExclusive,
        ),
        makeTx(
          id: 'txBeforeStart',
          amountMinor: 3000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: beforeStart,
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(summary.transactionCount, 1);
      expect(summary.expenseMinor, 1000);
    });

    test('8. Income and expense totals are separate (income 100.00 and expense 30.00 give 10000 and 3000, never a net)', () {
      final transactions = [
        makeTx(
          id: 'inc',
          amountMinor: 10000,
          currency: AppCurrency.usd,
          type: TransactionType.income,
          category: TransactionCategory.salary,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'exp',
          amountMinor: 3000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 11),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(summary.incomeMinor, 10000);
      expect(summary.expenseMinor, 3000);
    });

    test('9. Category breakdown counts only EXPENSE transactions: an income transaction with category other does not appear, while an expense with category other does', () {
      final transactions = [
        makeTx(
          id: 'incOther',
          amountMinor: 5000,
          currency: AppCurrency.usd,
          type: TransactionType.income,
          category: TransactionCategory.other,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'expOther',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.other,
          date: DateTime(2026, 10, 11),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(summary.categories.length, 1);
      expect(summary.categories.first.category, TransactionCategory.other);
      expect(summary.categories.first.amountMinor, 2000);
    });

    test('10. Categories are ordered by amount descending (hand-computed), with equal amounts ordered by category.index', () {
      // Index order: food (0), transport (1), shopping (2), salary (3), entertainment (4), other (5)
      final transactions = [
        makeTx(
          id: 'shop',
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.shopping,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'food',
          amountMinor: 3000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'ent',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.entertainment,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'trans',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          date: DateTime(2026, 10, 10),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      // Amounts: food (3000), transport (2000, index 1), entertainment (2000, index 4), shopping (1000, index 2)
      final catOrder = summary.categories.map((c) => c.category).toList();
      expect(catOrder, [
        TransactionCategory.food,
        TransactionCategory.transport,
        TransactionCategory.entertainment,
        TransactionCategory.shopping,
      ]);
    });

    test('11. Shares: expenses 7500 (food) and 2500 (transport) give shares 0.75 and 0.25 (use closeTo) that add up to 1.0', () {
      final transactions = [
        makeTx(
          id: 'food',
          amountMinor: 7500,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'trans',
          amountMinor: 2500,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          date: DateTime(2026, 10, 10),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      final foodCat = summary.categories.firstWhere(
        (c) => c.category == TransactionCategory.food,
      );
      final transCat = summary.categories.firstWhere(
        (c) => c.category == TransactionCategory.transport,
      );

      expect(foodCat.share, closeTo(0.75, 1e-6));
      expect(transCat.share, closeTo(0.25, 1e-6));
      expect(foodCat.share! + transCat.share!, closeTo(1.0, 1e-6));
    });

    test('12. Foreign currency: a category in a foreign currency is converted with the injected rate (hand-computed minor units)', () {
      // Target = USD. JOD has 3 decimals (minorFactor 1000), USD has 2 decimals (minorFactor 100).
      // 1000 fils JOD = 1.000 JOD. Rate JOD -> USD = 1.4.
      // 1.000 JOD * 1.4 = 1.40 USD = 140 cents.
      final transactions = [
        makeTx(
          id: 'jodFood',
          amountMinor: 1000,
          currency: AppCurrency.jod,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 10),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: (from, to) {
          if (from == AppCurrency.jod && to == AppCurrency.usd) return 1.4;
          throw UnimplementedError();
        },
      );

      expect(summary.categories.length, 1);
      expect(summary.categories.first.amountMinor, 140);
    });

    test('13. A rate failure for one category: that category amount is null, ALL shares are null, expenseMinor is null, while incomeMinor (target-currency only) stays numeric', () {
      final transactions = [
        makeTx(
          id: 'incUsd',
          amountMinor: 10000,
          currency: AppCurrency.usd,
          type: TransactionType.income,
          category: TransactionCategory.salary,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'foodUsd',
          amountMinor: 3000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'transJod',
          amountMinor: 1000,
          currency: AppCurrency.jod,
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          date: DateTime(2026, 10, 10),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate, // throws exception for JOD -> USD
      );

      expect(summary.incomeMinor, 10000);
      expect(summary.expenseMinor, isNull);

      final transCat = summary.categories.firstWhere(
        (c) => c.category == TransactionCategory.transport,
      );
      expect(transCat.amountMinor, isNull);

      for (final cat in summary.categories) {
        expect(cat.share, isNull);
      }
    });

    test('14. Empty period: incomeMinor 0, expenseMinor 0, categories empty, transactionCount 0 (not null)', () {
      final summary = buildAnalyticsSummary(
        transactions: [],
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(summary.incomeMinor, 0);
      expect(summary.expenseMinor, 0);
      expect(summary.categories, isEmpty);
      expect(summary.transactionCount, 0);
    });

    test('15. A transaction dated later in the CURRENT month counts for month but not for week', () {
      // now = 2026-10-14. Month = 2026-10-01 .. 2026-11-01. Week = 2026-10-08 .. 2026-10-15.
      final txDate = DateTime(2026, 10, 25);
      final transactions = [
        makeTx(
          id: 'lateInMonth',
          amountMinor: 1500,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: txDate,
        ),
      ];

      final monthSummary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      final weekSummary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.week,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(monthSummary.transactionCount, 1);
      expect(monthSummary.expenseMinor, 1500);

      expect(weekSummary.transactionCount, 0);
      expect(weekSummary.expenseMinor, 0);
    });

    test('16. A transaction older than the 12-month window start is excluded for year', () {
      // now = 2026-10-14. Year (12 months) = 2025-11-01 .. 2026-11-01.
      final oldTxDate = DateTime(2025, 10, 31, 23, 59, 59);
      final transactions = [
        makeTx(
          id: 'oldTx',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: oldTxDate,
        ),
      ];

      final yearSummary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.year,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(yearSummary.transactionCount, 0);
      expect(yearSummary.expenseMinor, 0);
    });

    test('17. Same-currency parity: expenseMinor equals the sum of category amounts exactly', () {
      final transactions = [
        makeTx(
          id: 'food',
          amountMinor: 5000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'trans',
          amountMinor: 3000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          date: DateTime(2026, 10, 10),
        ),
        makeTx(
          id: 'shop',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.shopping,
          date: DateTime(2026, 10, 10),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      final categorySum = summary.categories.fold<int>(
        0,
        (sum, c) => sum + c.amountMinor!,
      );
      expect(summary.expenseMinor, equals(categorySum));
      expect(summary.expenseMinor, 10000);
    });

    test('18. transactionCount counts only the in-period transactions', () {
      final transactions = [
        makeTx(
          id: 'txIn1',
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 10, 5),
        ),
        makeTx(
          id: 'txIn2',
          amountMinor: 2000,
          currency: AppCurrency.usd,
          type: TransactionType.income,
          category: TransactionCategory.salary,
          date: DateTime(2026, 10, 20),
        ),
        makeTx(
          id: 'txOut1',
          amountMinor: 1500,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 9, 15),
        ),
        makeTx(
          id: 'txOut2',
          amountMinor: 2500,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 11, 15),
        ),
      ];

      final summary = buildAnalyticsSummary(
        transactions: transactions,
        period: AnalyticsPeriod.month,
        now: now,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(summary.transactionCount, 2);
    });
  });
}
