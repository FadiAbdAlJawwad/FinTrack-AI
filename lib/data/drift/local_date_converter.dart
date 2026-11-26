import 'package:drift/drift.dart';

import '../../domain/time/local_date.dart';

class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter(this.table, this.column);

  final String table;
  final String column;

  @override
  LocalDate fromSql(String fromDb) {
    return LocalDate(2026, 1, 1);
  }

  @override
  String toSql(LocalDate value) {
    return '';
  }
}
