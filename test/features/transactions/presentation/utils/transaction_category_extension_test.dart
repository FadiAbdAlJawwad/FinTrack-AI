import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/utils/transaction_category_extension.dart';
import 'package:fin_track_ai/features/transactions/presentation/utils/transaction_ui_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionCategoryExtension regression tests', () {
    test(
      '14. category.icon equals TransactionModel.categoryIcon for all values',
      () {
        final now = DateTime.now();
        for (final cat in TransactionCategory.values) {
          final model = TransactionModel(
            id: 'test',
            title: 'Test',
            amountMinor: 1000,
            currency: AppCurrency.usd,
            date: now,
            type: TransactionType.expense,
            category: cat,
            walletId: 'cash',
          );
          expect(cat.icon, equals(model.categoryIcon));
        }
      },
    );
  });
}
