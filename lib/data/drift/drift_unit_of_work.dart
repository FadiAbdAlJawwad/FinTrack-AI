import 'dart:async';

import '../../domain/persistence/unit_of_work.dart';
import 'app_database.dart';

part 'unit_of_work_zone.dart';

class DriftUnitOfWork implements UnitOfWork {
  DriftUnitOfWork(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) async {
    if (inUnitOfWork) {
      throw StateError('Nested UnitOfWork.run is not allowed');
    }
    return _db.transaction(() => _runInUnitOfWorkZone(action));
  }
}
