import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/utils/money_format.dart';
import '../../../dashboard/presentation/state/dashboard_controller.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../state/period_totals_provider.dart';
import '../state/transaction_filters_provider.dart';
import '../utils/error_message.dart';
import '../utils/localized_date_format.dart';
import '../utils/transaction_group_label.dart';
import '../widgets/date_range_bottom_sheet.dart';
import '../widgets/transaction_list_tile.dart';

class TransactionsScreen extends HookConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final selectedFilter = ref.watch(transactionTypeFilterProvider);
    final selectedDateRange = ref.watch(transactionDateRangeFilterProvider);
    final effectivePeriod = ref.watch(transactionEffectivePeriodProvider);
    final periodTotals = ref.watch(periodTotalsProvider).valueOrNull;
    final filteredGroups = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.transactions),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(errorMessage(context, error))),
        data: (state) {
          return SafeArea(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterCard(
                        label: context.loc.all,
                        isSelected: selectedFilter == null,
                        onTap: () =>
                            ref
                                    .read(
                                      transactionTypeFilterProvider.notifier,
                                    )
                                    .state =
                                null,
                      ),
                      _FilterCard(
                        label: context.loc.income,
                        isSelected: selectedFilter == TransactionType.income,
                        onTap: () =>
                            ref
                                .read(transactionTypeFilterProvider.notifier)
                                .state = TransactionType
                                .income,
                      ),
                      _FilterCard(
                        label: context.loc.expense,
                        isSelected: selectedFilter == TransactionType.expense,
                        onTap: () =>
                            ref
                                .read(transactionTypeFilterProvider.notifier)
                                .state = TransactionType
                                .expense,
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: ColorManager.darkBackground,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            builder: (context) => DateRangeBottomSheet(
                              initialStartDate: effectivePeriod.start,
                              initialEndDate: effectivePeriod.end,
                              onApply: (start, end) {
                                ref
                                    .read(
                                      transactionDateRangeFilterProvider
                                          .notifier,
                                    )
                                    .state = DateTimeRange(
                                  start: start,
                                  end: end,
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          color: selectedDateRange != null
                              ? ColorManager.primaryBlue
                              : null,
                          child: Row(
                            children: [
                              Text(
                                selectedDateRange == null
                                    ? formatLocalizedDate(
                                        context,
                                        'MMMM',
                                        effectivePeriod.start,
                                      )
                                    : '${formatLocalizedDate(context, 'dd MMM', selectedDateRange.start)} - ${formatLocalizedDate(context, 'dd MMM', selectedDateRange.end)}',
                                style: context.labelSmall.copyWith(
                                  color: selectedDateRange != null
                                      ? ColorManager.white
                                      : null,
                                ),
                              ).padEnd(4),
                              Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: selectedDateRange != null
                                    ? ColorManager.white
                                    : null,
                              ),
                            ],
                          ).padSymmetric(16).padVerticalSymmetric(8),
                        ),
                      ),
                    ],
                  ).padStart(20),
                ),
                context.addVerticalSpace(8),
                IntrinsicHeight(
                  child: Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryColumn(
                            label: context.loc.totalIncome.toUpperCase(),
                            amountMinor: periodTotals?.incomeMinor,
                            currency: state.currency,
                            color: ColorManager.successColor,
                          ),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          child: _SummaryColumn(
                            label: context.loc.totalExpense.toUpperCase(),
                            amountMinor: periodTotals?.expenseMinor,
                            currency: state.currency,
                            color: ColorManager.errorColor,
                          ),
                        ),
                      ],
                    ).padVerticalSymmetric(8),
                  ),
                ),
                context.addVerticalSpace(24),
                if (filteredGroups.isEmpty)
                  Expanded(
                    child: Center(child: Text(context.loc.emptyTransactions)),
                  )
                else
                  Expanded(
                    child: ListView(
                      children: filteredGroups.entries.map((group) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.key.label(context.loc),
                              style: context.labelSmall.copyWith(
                                color: ColorManager.secondaryColor,
                              ),
                            ),
                            context.addVerticalSpace(8),
                            ListView.separated(
                              itemCount: group.value.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  context.addVerticalSpace(8),
                              itemBuilder: (context, index) {
                                return TransactionListTile(
                                  transaction: group.value[index],
                                );
                              },
                            ),
                            context.addVerticalSpace(16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                context.addVerticalSpace(15),
              ],
            ).padSymmetric(20),
          );
        },
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? ColorManager.primaryBlue : null,
        child: Text(
          label,
          style: context.labelSmall.copyWith(
            color: isSelected ? ColorManager.white : null,
          ),
        ).padSymmetric(16).padVerticalSymmetric(8),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;

  /// `null` when the total is unknown (rates unavailable).
  final int? amountMinor;
  final AppCurrency currency;
  final Color color;

  const _SummaryColumn({
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: ColorManager.secondaryColor,
          ),
        ),
        context.addVerticalSpace(4),
        Text(
          amountMinor == null ? '—' : formatMoney(amountMinor!, currency),
          style: context.headlineMedium.copyWith(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).padSymmetric(16);
  }
}
