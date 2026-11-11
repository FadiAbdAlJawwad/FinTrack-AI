import '../../../currency/domain/models/app_currency.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/domain/usecases/calculate_totals_usecase.dart';
import '../../../transactions/domain/usecases/convert_totals_usecase.dart';
import '../models/wallet_model.dart';
import '../models/wallets_overview.dart';

/// Builds a [WalletsOverview] from the given [wallets] and [transactions].
///
/// Rounding note: Because each wallet's totals are converted to the target
/// currency individually, the sum of all wallet balances might differ by a few
/// minor units from the Home screen's balance (which converts the grand total
/// of all transactions at once) when foreign currencies are involved.
WalletsOverview buildWalletsOverview({
  required List<WalletModel> wallets,
  required List<TransactionModel> transactions,
  required AppCurrency target,
  required double Function(AppCurrency from, AppCurrency to) rateBetween,
}) {
  final Map<String, List<TransactionModel>> transactionsByWallet = {};
  final List<TransactionModel> unassignedTransactions = [];
  final Set<String> validWalletIds = {};

  for (final wallet in wallets) {
    if (wallet.id != null) {
      validWalletIds.add(wallet.id!);
      transactionsByWallet[wallet.id!] = [];
    }
  }

  for (final tx in transactions) {
    if (validWalletIds.contains(tx.walletId)) {
      transactionsByWallet[tx.walletId]!.add(tx);
    } else {
      unassignedTransactions.add(tx);
    }
  }

  final sortedWallets = List<WalletModel>.of(wallets);
  sortedWallets.sort((a, b) {
    if (a.isDefault && !b.isDefault) return -1;
    if (!a.isDefault && b.isDefault) return 1;
    final nameCompare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (nameCompare != 0) return nameCompare;
    return (a.id ?? '').compareTo(b.id ?? '');
  });

  int? getBalanceMinor(List<TransactionModel> txs, {WalletModel? wallet}) {
    if (txs.isEmpty && (wallet == null || wallet.openingBalanceMinor == null)) return 0;
    
    final calculated = calculateTotals(txs);
    
    if (wallet != null && wallet.openingBalanceMinor != null && wallet.openingBalanceCurrency != null) {
      final currency = wallet.openingBalanceCurrency!;
      final current = calculated[currency] ?? const CurrencyTotals(incomeMinor: 0, expenseMinor: 0);
      calculated[currency] = CurrencyTotals(
        incomeMinor: current.incomeMinor + wallet.openingBalanceMinor!,
        expenseMinor: current.expenseMinor,
      );
    }
    
    final converted = convertTotals(calculated, target, rateBetween);
    
    if (converted.incomeMinor == null || converted.expenseMinor == null) {
      return null;
    }
    
    return converted.incomeMinor! - converted.expenseMinor!;
  }

  final walletBalances = <WalletBalance>[];
  int? totalMinor = 0;
  bool totalHasNull = false;

  for (final wallet in sortedWallets) {
    int? balanceMinor;
    if (wallet.id == null) {
      balanceMinor = getBalanceMinor([], wallet: wallet);
    } else {
      balanceMinor = getBalanceMinor(transactionsByWallet[wallet.id!]!, wallet: wallet);
    }
    
    walletBalances.add(
      WalletBalance(
        wallet: wallet,
        balanceMinor: balanceMinor,
      ),
    );
    
    if (balanceMinor == null) {
      totalHasNull = true;
    } else if (!totalHasNull && totalMinor != null) {
      totalMinor += balanceMinor;
    }
  }

  final unassignedMinor = getBalanceMinor(unassignedTransactions);
  if (unassignedMinor == null) {
    totalHasNull = true;
  } else if (!totalHasNull && totalMinor != null) {
    totalMinor += unassignedMinor;
  }

  return WalletsOverview(
    currency: target,
    wallets: walletBalances,
    unassignedMinor: unassignedMinor,
    hasUnassigned: unassignedTransactions.isNotEmpty,
    totalMinor: totalHasNull ? null : totalMinor,
  );
}
