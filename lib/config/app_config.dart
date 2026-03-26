class AppConfig {
  // Update this with your actual backend URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000', // Default to local development
    // For production with HTTPS: 'https://your-domain.com'
    // For Android emulator: 'http://10.0.2.2:8000'
    // For physical device on local network: 'http://192.168.1.124:8000'
    // For web/production: MUST use HTTPS (https://...)
  );

  static const String apiPath = '/api';
  static const String authPath = '/api/auth';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
