import '../drift/app_database.dart';
import '../drift/drift_unit_of_work.dart';
import 'pulled_doc.dart';

class PulledDocApplier {
  PulledDocApplier(this._db);

  final AppDatabase _db;

  Future<void> apply(List<PulledDoc> docs) async {
    assertNotInUnitOfWork();
    await _db.transaction(() async {
      for (final doc in docs) {
        switch (doc) {
          case PulledWallet(:final row):
            await _db.into(_db.wallets).insertOnConflictUpdate(row);
          case PulledTransaction(:final row):
            await _db.into(_db.transactions).insertOnConflictUpdate(row);
        }
      }
    });
  }
}
