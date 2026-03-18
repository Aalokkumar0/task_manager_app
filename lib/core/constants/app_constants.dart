class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Mock API – simulated base URL (no real server)
  static const String baseUrl = 'https://mock.taskmanager.api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Misc
  static const String appName = 'Task Manager';
}
