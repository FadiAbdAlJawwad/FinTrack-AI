enum CurrencyErrorType {
  notAuthenticated,
  permissionDenied,
  networkError,
  unknown,
}

class CurrencyException implements Exception {
  final CurrencyErrorType type;
  final String? message;

  CurrencyException(this.type, {this.message});

  @override
  String toString() => 'CurrencyException: $type ${message ?? ""}';
}
