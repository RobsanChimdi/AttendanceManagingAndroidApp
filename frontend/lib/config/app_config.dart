class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get wsBaseUrl => apiBaseUrl.replaceFirst('http', 'ws');
}
