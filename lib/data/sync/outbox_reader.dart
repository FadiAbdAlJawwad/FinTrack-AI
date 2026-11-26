import '../drift/app_database.dart';

class OutboxReader {
  OutboxReader(this._db);

  // Unused in stub, stored for implementation step.
  // ignore: unused_field
  final AppDatabase _db;

  Future<List<OutboxEntryDto>> readAll() async {
    return [];
  }
}
