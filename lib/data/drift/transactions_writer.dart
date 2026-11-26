import 'app_database.dart';

class TransactionsWriter {
  TransactionsWriter(this._db, this._utcNow);

  // Unused in stub, stored for implementation step.
  // ignore: unused_field
  final AppDatabase _db;
  // ignore: unused_field
  final DateTime Function() _utcNow;

  Future<void> saveTransfer(TransactionDto transfer, TransactionDto? fee) async {}

  Future<void> deleteTransfer(String transferId) async {}
}
