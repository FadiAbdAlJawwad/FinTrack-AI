import 'package:drift/drift.dart';

import '../../domain/time/local_date.dart';
import 'corrupt_stored_value_exception.dart';

class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter(this.table, this.column);

  final String table;
  final String column;

  @override
  LocalDate fromSql(String fromDb) {
    final d = LocalDate.tryParse(fromDb);
    if (d == null || d.toIso8601String() != fromDb) {
      throw CorruptStoredValueException(table, column, fromDb);
    }
    return d;
  }

  @override
  String toSql(LocalDate value) {
    return value.toIso8601String();
  }
}
