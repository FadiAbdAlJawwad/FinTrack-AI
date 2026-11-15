enum AuthErrorType {
  userNotFound,
  wrongPassword,
  invalidCredential,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userDisabled,
  tooManyRequests,
  networkRequestFailed,
  databaseError,
  biometricDenied,
  googleSignInCanceled,
  sessionExpired,
  unknown,
}

class AppAuthException implements Exception {
  final AuthErrorType type;
  final String? message;

  AppAuthException(this.type, {this.message});

  @override
  String toString() => 'AppAuthException: $type ${message ?? ""}';
}
