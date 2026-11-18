import '../../../transactions/domain/models/transaction_model.dart';

bool walletHasTransactions(
  List<TransactionModel> transactions,
  String walletId,
) {
  return transactions.any((t) => t.walletId == walletId);
}
