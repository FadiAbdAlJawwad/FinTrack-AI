import 'package:drift/drift.dart';

import '../drift/app_database.dart';

class OutboxReader {
  OutboxReader(this._db);

  final AppDatabase _db;

  Future<List<OutboxEntryDto>> readAll() async {
    return (_db.select(_db.outbox)..orderBy([
          (o) => OrderingTerm(expression: o.seq, mode: OrderingMode.asc),
        ]))
        .get();
  }
}
