import '../../../currency/domain/models/app_currency.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/domain/transaction_limits.dart';
import '../../../transactions/domain/usecases/calculate_totals_usecase.dart';
import '../../../transactions/domain/usecases/convert_totals_usecase.dart';
import '../models/analytics_period.dart';
import '../models/analytics_summary.dart';
import 'analytics_period_range.dart';

/// Builds an [AnalyticsSummary] for the given [transactions] and [period].
///
/// Note: The sum of category amounts may differ by a few minor units from
/// [AnalyticsSummary.expenseMinor] when foreign currencies are involved (each
/// category is converted separately).
AnalyticsSummary buildAnalyticsSummary({
  required List<TransactionModel> transactions,
  required AnalyticsPeriod period,
  required DateTime now,
  required AppCurrency target,
  required double Function(AppCurrency from, AppCurrency to) rateBetween,
  int windowMonths = transactionWindowMonths,
}) {
  final range = analyticsPeriodRange(period, now, windowMonths: windowMonths);
  final start = range.start;
  final endExclusive = range.endExclusive;

  final kept = transactions
      .where((tx) => !tx.date.isBefore(start) && tx.date.isBefore(endExclusive))
      .toList();

  final totals = convertTotals(calculateTotals(kept), target, rateBetween);

  final expenseTxs = kept
      .where((tx) => tx.type == TransactionType.expense)
      .toList();

  final Map<TransactionCategory, List<TransactionModel>> categoryGroups = {};
  for (final tx in expenseTxs) {
    (categoryGroups[tx.category] ??= []).add(tx);
  }

  final Map<TransactionCategory, int?> categoryAmounts = {};
  for (final MapEntry(key: category, value: catTxs) in categoryGroups.entries) {
    categoryAmounts[category] = convertTotals(
      calculateTotals(catTxs),
      target,
      rateBetween,
    ).expenseMinor;
  }

  final hasNullAmount = categoryAmounts.values.any((a) => a == null);
  final totalSum = hasNullAmount
      ? 0
      : categoryAmounts.values.fold<int>(0, (sum, a) => sum + a!);

  final bool canComputeShare = !hasNullAmount && totalSum > 0;

  final List<CategoryExpense> categories = [];
  for (final MapEntry(key: category, value: amountMinor)
      in categoryAmounts.entries) {
    final double? share = canComputeShare ? (amountMinor! / totalSum) : null;
    categories.add(
      CategoryExpense(
        category: category,
        amountMinor: amountMinor,
        share: share,
      ),
    );
  }

  categories.sort((a, b) {
    if (a.amountMinor == null && b.amountMinor == null) {
      return a.category.index.compareTo(b.category.index);
    }
    if (a.amountMinor == null) return 1;
    if (b.amountMinor == null) return -1;
    final amountCompare = b.amountMinor!.compareTo(a.amountMinor!);
    if (amountCompare != 0) return amountCompare;
    return a.category.index.compareTo(b.category.index);
  });

  return AnalyticsSummary(
    period: period,
    currency: target,
    incomeMinor: totals.incomeMinor,
    expenseMinor: totals.expenseMinor,
    categories: categories,
    transactionCount: kept.length,
  );
}
