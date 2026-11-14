import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/calculate_totals_usecase.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/convert_totals_usecase.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/usecases/build_wallets_overview_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildWalletsOverview', () {
    WalletModel w(String id, String name, {bool isDefault = false}) =>
        WalletModel(
          id: id,
          name: name,
          icon: 'wallet',
          isDefault: isDefault,
        );

    TransactionModel tx(
      String walletId,
      TransactionType type,
      int amountMinor,
      AppCurrency currency,
    ) =>
        TransactionModel(
          id: 'tx-${DateTime.now().microsecondsSinceEpoch}',
          amountMinor: amountMinor,
          currency: currency,
          type: type,
          category: TransactionCategory.other,
          title: 't',
          date: DateTime.now(),
          walletId: walletId,
        );

    double noRate(AppCurrency from, AppCurrency to) {
      if (from == to) return 1.0;
      throw Exception('No rate available');
    }

    test('1. One wallet, income 100.00 and expense 30.00 in the same currency -> balance 70.00', () {
      final wallets = [w('w1', 'Wallet 1')];
      final transactions = [
        tx('w1', TransactionType.income, 10000, AppCurrency.usd),
        tx('w1', TransactionType.expense, 3000, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.length, 1);
      expect(overview.wallets.first.balanceMinor, 7000);
      expect(overview.unassignedMinor, 0);
      expect(overview.totalMinor, 7000);
    });

    test('2. A wallet with only expenses -> negative balance', () {
      final wallets = [w('w1', 'Wallet 1')];
      final transactions = [
        tx('w1', TransactionType.expense, 2500, AppCurrency.usd),
        tx('w1', TransactionType.expense, 1500, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, -4000);
      expect(overview.totalMinor, -4000);
    });

    test('3. Two wallets get separate balances from their own transactions only', () {
      final wallets = [w('w1', 'W1'), w('w2', 'W2')];
      final transactions = [
        tx('w1', TransactionType.income, 5000, AppCurrency.usd),
        tx('w2', TransactionType.expense, 2000, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.firstWhere((wb) => wb.wallet.id == 'w1').balanceMinor, 5000);
      expect(overview.wallets.firstWhere((wb) => wb.wallet.id == 'w2').balanceMinor, -2000);
      expect(overview.totalMinor, 3000);
    });

    test('4. A wallet with no transactions -> 0, not null', () {
      final wallets = [w('w1', 'W1')];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [],
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, 0);
      expect(overview.totalMinor, 0);
    });

    test('5. A transaction whose walletId matches no wallet -> counted in unassignedMinor and included in totalMinor', () {
      final wallets = [w('w1', 'W1')];
      final transactions = [
        tx('w1', TransactionType.income, 3000, AppCurrency.usd),
        tx('w2', TransactionType.income, 2000, AppCurrency.usd), // no wallet matches w2
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, 3000);
      expect(overview.unassignedMinor, 2000);
      expect(overview.totalMinor, 5000);
    });

    test('6. No wallets at all, some transactions -> everything unassigned, total equals that amount', () {
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.usd),
        tx('w2', TransactionType.expense, 400, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: [],
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.isEmpty, isTrue);
      expect(overview.unassignedMinor, 600);
      expect(overview.totalMinor, 600);
    });

    test('7. Same-currency data: totalMinor equals convertTotals(calculateTotals(all), target, rate) balance exactly (Home parity)', () {
      final wallets = [w('w1', 'W1'), w('w2', 'W2')];
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.usd),
        tx('w2', TransactionType.expense, 300, AppCurrency.usd),
        tx('orphan', TransactionType.expense, 50, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      final calculated = calculateTotals(transactions);
      final converted = convertTotals(calculated, AppCurrency.usd, noRate);
      final homeBalance = converted.incomeMinor! - converted.expenseMinor!;

      expect(overview.totalMinor, homeBalance);
      expect(overview.totalMinor, 650);
    });

    test('8. Foreign-currency transactions are converted with the injected rate', () {
      final wallets = [w('w1', 'W1')];
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.ils), // 10.00 ILS -> 11.00 USD -> 1100 cents
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: (from, to) {
          if (from == AppCurrency.ils && to == AppCurrency.usd) return 1.1;
          throw Exception();
        },
      );

      expect(overview.wallets.first.balanceMinor, 1100);
      expect(overview.totalMinor, 1100);
    });

    test('9. A rate failure for one wallet foreign currency -> that wallet balance is null and totalMinor is null, while another wallet keeps its numeric balance', () {
      final wallets = [w('w1', 'W1'), w('w2', 'W2')];
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.ils),
        tx('w2', TransactionType.income, 500, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      final b1 = overview.wallets.firstWhere((wb) => wb.wallet.id == 'w1').balanceMinor;
      final b2 = overview.wallets.firstWhere((wb) => wb.wallet.id == 'w2').balanceMinor;

      expect(b1, isNull);
      expect(b2, 500);
      expect(overview.totalMinor, isNull);
    });

    test('10. Multiple currencies inside one wallet are never summed before conversion', () {
      final wallets = [w('w1', 'W1')];
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.usd), // 10.00 USD -> 1000 cents
        tx('w1', TransactionType.expense, 500, AppCurrency.ils), // 5.00 ILS -> 5.50 USD -> 550 cents
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: (from, to) {
          if (from == AppCurrency.ils && to == AppCurrency.usd) return 1.1;
          if (from == to) return 1.0;
          throw Exception();
        },
      );

      // If they were summed before conversion: (1000 - 500) = 500, then converted would be wrong.
      // Correct: 1000 - 550 = 450.
      expect(overview.wallets.first.balanceMinor, 450);
    });

    test('11. Ordering: default wallet first, then name case-insensitive', () {
      final wallets = [
        w('w1', 'Zebra'),
        w('w2', 'apple'),
        w('w3', 'Banana', isDefault: true),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [],
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets[0].wallet.name, 'Banana');
      expect(overview.wallets[1].wallet.name, 'apple');
      expect(overview.wallets[2].wallet.name, 'Zebra');
    });

    test('12. A wallet with a null id gets 0 and does not crash', () {
      final wallets = [
        WalletModel(name: 'New', icon: 'wallet', isDefault: false) // null id
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [tx('w1', TransactionType.income, 1000, AppCurrency.usd)], // will be unassigned
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, 0);
      expect(overview.unassignedMinor, 1000);
    });

    test('13. Mixed-currency drift: bound test', () {
      final wallets = [w('w1', 'W1'), w('w2', 'W2')];
      // 0.33 JOD * 1.41 = 0.4653 USD -> 47 cents each if rounded per transaction/wallet.
      // Total 0.66 JOD * 1.41 = 0.9306 USD -> 93 cents if rounded globally.
      final transactions = [
        tx('w1', TransactionType.income, 330, AppCurrency.jod),
        tx('w2', TransactionType.income, 330, AppCurrency.jod),
      ];

      double rate(AppCurrency from, AppCurrency to) {
        if (from == AppCurrency.jod && to == AppCurrency.usd) return 1.41;
        return 1.0;
      }

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: rate,
      );

      final calculated = calculateTotals(transactions);
      final converted = convertTotals(calculated, AppCurrency.usd, rate);
      final homeBalance = converted.incomeMinor! - converted.expenseMinor!;

      // w1 balance = 47
      // w2 balance = 47
      // totalMinor = 94
      // homeBalance = 93
      // Drift = 94 - 93 = 1
      expect(overview.totalMinor, 94);
      expect(homeBalance, 93);
      final diff = (overview.totalMinor! - homeBalance).abs();
      expect(diff, lessThanOrEqualTo(1));
    });

    test('14. Ordering tiebreaker: two wallets with equal names are ordered by id deterministically', () {
      final wallets = [
        w('w_beta', 'Savings'),
        w('w_alpha', 'Savings'),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [],
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets[0].wallet.id, 'w_alpha');
      expect(overview.wallets[1].wallet.id, 'w_beta');
    });

    test('15. Orphans netting to 0: hasUnassigned is true and unassignedMinor is 0', () {
      final wallets = [w('w1', 'Cash')];
      final transactions = [
        tx('orphan', TransactionType.income, 1000, AppCurrency.usd),
        tx('orphan', TransactionType.expense, 1000, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.hasUnassigned, isTrue);
      expect(overview.unassignedMinor, equals(0));
    });

    test('16. No orphans: hasUnassigned is false', () {
      final wallets = [w('w1', 'Cash')];
      final transactions = [
        tx('w1', TransactionType.income, 1000, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.hasUnassigned, isFalse);
    });

    test('17. Wallet with opening balance only -> uses opening balance', () {
      final wallets = [
        const WalletModel(
          id: 'w1',
          name: 'Bank',
          icon: 'bank',
          openingBalanceMinor: 10000,
          openingBalanceCurrency: AppCurrency.usd,
        ),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [],
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, 10000);
      expect(overview.totalMinor, 10000);
    });

    test('18. Opening balance plus same-currency transactions are summed before conversion', () {
      final wallets = [
        const WalletModel(
          id: 'w1',
          name: 'Bank',
          icon: 'bank',
          openingBalanceMinor: 5000,
          openingBalanceCurrency: AppCurrency.usd,
        ),
      ];
      final transactions = [
        tx('w1', TransactionType.income, 2000, AppCurrency.usd),
        tx('w1', TransactionType.expense, 1000, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: noRate,
      );

      expect(overview.wallets.first.balanceMinor, 6000); // 5000 + 2000 - 1000
    });

    test('19. Opening balance in a different currency than the transactions -> converted individually', () {
      final wallets = [
        const WalletModel(
          id: 'w1',
          name: 'Bank',
          icon: 'bank',
          openingBalanceMinor: 1000,
          openingBalanceCurrency: AppCurrency.jod, // 1 JOD -> 1.41 USD -> 141 cents
        ),
      ];
      final transactions = [
        tx('w1', TransactionType.expense, 50, AppCurrency.usd),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: AppCurrency.usd,
        rateBetween: (from, to) {
          if (from == AppCurrency.jod && to == AppCurrency.usd) return 1.41;
          if (from == to) return 1.0;
          throw Exception();
        },
      );

      expect(overview.wallets.first.balanceMinor, 91); // 141 - 50 = 91
      expect(overview.totalMinor, 91);
    });

    test('20. Missing rate for opening balance currency makes wallet balance null', () {
      final wallets = [
        const WalletModel(
          id: 'w1',
          name: 'Bank',
          icon: 'bank',
          openingBalanceMinor: 1000,
          openingBalanceCurrency: AppCurrency.jod,
        ),
        w('w2', 'Cash'),
      ];

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: [],
        target: AppCurrency.usd,
        rateBetween: (from, to) {
          if (from == to) return 1.0;
          throw Exception();
        },
      );

      expect(overview.wallets.firstWhere((w) => w.wallet.id == 'w1').balanceMinor, isNull);
      expect(overview.wallets.firstWhere((w) => w.wallet.id == 'w2').balanceMinor, 0);
      expect(overview.totalMinor, isNull);
    });
  });
}
