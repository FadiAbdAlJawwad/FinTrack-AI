import 'package:drift/drift.dart';

import '../../domain/time/local_date.dart';
import 'local_date_converter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Wallets,
  Categories,
  Transactions,
  Budgets,
  Rates,
  Preferences,
  Outbox,
  NeedsAttention,
  SyncCursors,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
