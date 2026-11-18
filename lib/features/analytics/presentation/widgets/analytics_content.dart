import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../transactions/domain/transaction_limits.dart';
import '../../domain/models/analytics_period.dart';
import '../../domain/models/analytics_summary.dart';
import 'analytics_totals_row.dart';
import 'category_expense_tile.dart';

class AnalyticsContent extends StatelessWidget {
  final AnalyticsSummary summary;

  const AnalyticsContent({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isEmpty = summary.transactionCount == 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.period == AnalyticsPeriod.year) ...[
            Text(
              context.loc.transactionsWindowNote(transactionWindowMonths),
              style: context.bodyMedium.copyWith(
                color: ColorManager.secondaryColor,
              ),
            ),
            context.addVerticalSpace(16),
          ],
          if (isEmpty) ...[
            context.addVerticalSpace(40),
            Center(
              child: Text(
                context.loc.analyticsEmpty,
                style: context.bodyMedium.copyWith(
                  color: ColorManager.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            AnalyticsTotalsRow(
              incomeMinor: summary.incomeMinor,
              expenseMinor: summary.expenseMinor,
              currency: summary.currency,
            ),
            context.addVerticalSpace(24),
            Text(
              context.loc.analyticsExpensesByCategory,
              style: context.labelLarge,
            ),
            context.addVerticalSpace(12),
            ...summary.categories.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CategoryExpenseTile(
                  item: item,
                  currency: summary.currency,
                ),
              ),
            ),
          ],
          context.addVerticalSpace(80),
        ],
      ).padSymmetric(20),
    );
  }
}
