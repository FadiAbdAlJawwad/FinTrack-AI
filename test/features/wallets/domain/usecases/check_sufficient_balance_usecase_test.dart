import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/wallets/domain/usecases/check_sufficient_balance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkSufficientBalanceUseCase', () {
    double dummyRateBetween(AppCurrency from, AppCurrency to) {
      if (from == to) return 1.0;
      if (from == AppCurrency.jod && to == AppCurrency.usd) return 1.4;
      throw UnimplementedError('No exchange rate for $from to $to');
    }

    test('income always true', () {
      final result = hasSufficientBalance(
        walletBalanceMinor: 100,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.income,
        rateBetween: dummyRateBetween,
      );
      expect(result, isTrue);
    });

    test('balance exactly equal to amount true', () {
      final result = hasSufficientBalance(
        walletBalanceMinor: 1000,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(result, isTrue);
    });

    test('one minor unit short false', () {
      final result = hasSufficientBalance(
        walletBalanceMinor: 999,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(result, isFalse);
    });

    test('null balance true', () {
      final result = hasSufficientBalance(
        walletBalanceMinor: null,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(result, isTrue);
    });

    test('rate throws true', () {
      final result = hasSufficientBalance(
        walletBalanceMinor: 500,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.ils, // dummyRateBetween throws for ILS
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(result, isTrue);
    });

    test('different currency converted with a fixed rate', () {
      // 1000 JOD minor (1 JOD) converted to USD @ rate 1.4 = 140 USD minor ($1.40).
      final sufficient = hasSufficientBalance(
        walletBalanceMinor: 140,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.jod,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(sufficient, isTrue);

      final insufficient = hasSufficientBalance(
        walletBalanceMinor: 139,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.jod,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
      );
      expect(insufficient, isFalse);
    });

    test('edit replacement makes an otherwise-failing amount pass', () {
      // wallet balance is 500. expense amount is 1000. Without replacement -> fails.
      // With replacement of 600, available = 500 + 600 = 1100 -> passes.
      final result = hasSufficientBalance(
        walletBalanceMinor: 500,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        replacedAmountMinorInBase: 600,
        rateBetween: dummyRateBetween,
      );
      expect(result, isTrue);
    });

    test('walletHasHistory false returns true; true enforces balance', () {
      final withoutHistory = hasSufficientBalance(
        walletBalanceMinor: 0,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
        walletHasHistory: false,
      );
      expect(withoutHistory, isTrue);

      final withHistory = hasSufficientBalance(
        walletBalanceMinor: 0,
        baseCurrency: AppCurrency.usd,
        amountMinor: 1000,
        amountCurrency: AppCurrency.usd,
        type: TransactionType.expense,
        rateBetween: dummyRateBetween,
        walletHasHistory: true,
      );
      expect(withHistory, isFalse);
    });
  });
}
