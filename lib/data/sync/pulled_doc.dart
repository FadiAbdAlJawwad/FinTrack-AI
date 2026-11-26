import '../drift/app_database.dart';

sealed class PulledDoc {
  const PulledDoc();
}

final class PulledWallet extends PulledDoc {
  const PulledWallet(this.row);

  final WalletDto row;
}

final class PulledTransaction extends PulledDoc {
  const PulledTransaction(this.row);

  final TransactionDto row;
}
