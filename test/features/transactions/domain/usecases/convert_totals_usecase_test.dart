import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/calculate_totals_usecase.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/convert_totals_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('convertTotals', () {
    test('returns null for the affected total when the rate lookup throws', () {
      final result = convertTotals(
        {
          AppCurrency.usd: const CurrencyTotals(
            incomeMinor: 1000,
            expenseMinor: 0,
          ),
          AppCurrency.ils: const CurrencyTotals(
            incomeMinor: 0,
            expenseMinor: 300,
          ),
        },
        AppCurrency.usd,
        (from, to) => throw Exception('No rate available'),
      );

      expect(result.incomeMinor, 1000);
      expect(result.expenseMinor, isNull);
    });
  });
}
