// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://api-test.aiwel.org/api/v1';
  static const String requestOtpEndpoint = '$baseUrl/login_with_otp';
  static const String verifyOtpEndpoint = '$baseUrl/verify_otp';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
  };
}