import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/usecases/group_transactions_usecase.dart';
import 'transaction_controller.dart';

final transactionTypeFilterProvider =
    StateProvider.autoDispose<TransactionType?>((ref) => null);

final transactionDateRangeFilterProvider =
    StateProvider.autoDispose<DateTimeRange?>((ref) => null);

final transactionEffectivePeriodProvider = Provider.autoDispose<DateTimeRange>((
  ref,
) {
  final dateFilter = ref.watch(transactionDateRangeFilterProvider);
  if (dateFilter != null) return dateFilter;
  final now = ref.watch(clockProvider)();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0),
  );
});

final filteredTransactionsProvider =
    Provider.autoDispose<Map<TransactionGroup, List<TransactionModel>>>((ref) {
      final transactionsAsync = ref.watch(transactionControllerProvider);
      final typeFilter = ref.watch(transactionTypeFilterProvider);
      final effectivePeriod = ref.watch(transactionEffectivePeriodProvider);
      final now = ref.watch(clockProvider)();

      return transactionsAsync.when(
        data: (transactions) {
          final grouped = groupTransactions(transactions, now: now);
          return Map.fromEntries(
            grouped.entries
                .map((e) {
                  final filteredList = e.value.where((tx) {
                    final typeMatch =
                        typeFilter == null || tx.type == typeFilter;
                    final dateMatch =
                        tx.date.isAfter(
                          effectivePeriod.start.subtract(
                            const Duration(seconds: 1),
                          ),
                        ) &&
                        tx.date.isBefore(
                          effectivePeriod.end.add(const Duration(days: 1)),
                        );
                    return typeMatch && dateMatch;
                  }).toList();
                  return MapEntry(e.key, filteredList);
                })
                .where((e) => e.value.isNotEmpty),
          );
        },
        loading: () => {},
        error: (e, st) => {},
      );
    });
