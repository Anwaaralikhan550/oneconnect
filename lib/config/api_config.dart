class ApiConfig {
  // Configure via: --dart-define=ONECONNECT_API_BASE_URL=https://your-api/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: String.fromEnvironment(
      'ONECONNECT_API_BASE_URL',
      defaultValue: 'http://192.168.100.50:3000/api/v1',
    ),
  );

  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
