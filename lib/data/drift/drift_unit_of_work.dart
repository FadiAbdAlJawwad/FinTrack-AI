import '../../domain/persistence/unit_of_work.dart';
import 'app_database.dart';

class DriftUnitOfWork implements UnitOfWork {
  DriftUnitOfWork(this._db);

  // Unused in stub, stored for implementation step.
  // ignore: unused_field
  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) async {
    return action();
  }
}
