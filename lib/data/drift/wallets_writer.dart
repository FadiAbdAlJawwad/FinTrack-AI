import 'app_database.dart';

class WalletsWriter {
  WalletsWriter(this._db, this._utcNow);

  // Unused in stub, stored for implementation step.
  // ignore: unused_field
  final AppDatabase _db;
  // ignore: unused_field
  final DateTime Function() _utcNow;

  Future<void> create(WalletDto wallet) async {}

  Future<void> update(String id, WalletDto wallet) async {}
}
