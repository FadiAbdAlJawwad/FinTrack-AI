final class LocalDate implements Comparable<LocalDate> {
  /// Creates a validated [LocalDate].
  ///
  /// Throws [ArgumentError] if [year], [month], and [day] do not form a valid calendar date.
  factory LocalDate(int year, int month, int day) => throw UnimplementedError();

  factory LocalDate.parse(String text) => throw UnimplementedError();

  static LocalDate? tryParse(String text) => throw UnimplementedError();

  // ignore: unused_element
  const LocalDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  String toIso8601String() => throw UnimplementedError();

  bool isAfter(LocalDate other) => throw UnimplementedError();

  @override
  int compareTo(LocalDate other) => throw UnimplementedError();

  @override
  bool operator ==(Object other) => throw UnimplementedError();

  @override
  int get hashCode => throw UnimplementedError();
}
