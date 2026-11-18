class AppEnv {
  const AppEnv._();

  static const String appsScriptProxyUrl = String.fromEnvironment(
    'APPS_SCRIPT_PROXY_URL',
  );
  static const String appSharedSecret = String.fromEnvironment(
    'APP_SHARED_SECRET',
  );

  static bool isAiConfigValid({
    required String proxyUrl,
    required String secret,
  }) {
    if (secret.trim().isEmpty) return false;
    final uri = Uri.tryParse(proxyUrl);
    if (uri == null) return false;
    if (!uri.isAbsolute || uri.scheme != 'https' || uri.host.isEmpty) {
      return false;
    }
    return true;
  }

  static final bool isAiConfigured = isAiConfigValid(
    proxyUrl: appsScriptProxyUrl,
    secret: appSharedSecret,
  );
}
