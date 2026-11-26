import '../drift/app_database.dart';
import 'pulled_doc.dart';

class PulledDocApplier {
  PulledDocApplier(this._db);

  // Unused in stub, stored for implementation step.
  // ignore: unused_field
  final AppDatabase _db;

  Future<void> apply(List<PulledDoc> docs) async {}
}
