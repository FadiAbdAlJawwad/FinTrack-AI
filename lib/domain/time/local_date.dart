final class LocalDate implements Comparable<LocalDate> {
  /// Creates a validated [LocalDate].
  ///
  /// Throws [ArgumentError] if [year], [month], and [day] do not form a valid calendar date.
  factory LocalDate(int year, int month, int day) {
    if (year < 1 || year > 9999) {
      throw ArgumentError('Year out of range (1..9999): $year');
    }
    final dt = DateTime.utc(year, month, day);
    if (dt.year != year || dt.month != month || dt.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
    return LocalDate._(year, month, day);
  }

  factory LocalDate.parse(String text) {
    final result = tryParse(text);
    if (result == null) {
      throw FormatException('Invalid ISO 8601 date: $text');
    }
    return result;
  }

  static LocalDate? tryParse(String text) {
    final match = _isoDatePattern.firstMatch(text.trim());
    if (match == null) {
      return null;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);

    try {
      return LocalDate(year, month, day);
    } on ArgumentError {
      return null;
    }
  }

  static final RegExp _isoDatePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  const LocalDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  String toIso8601String() {
    final y = year.abs().toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    final sign = year < 0 ? '-' : '';
    return '$sign$y-$m-$d';
  }

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
