class CorruptStoredValueException implements Exception {
  const CorruptStoredValueException(this.table, this.column, this.rawValue);

  final String table;
  final String column;
  final String rawValue;

  @override
  String toString() =>
      'CorruptStoredValueException: table=$table, column=$column, rawValue=$rawValue';
}
