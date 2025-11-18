class Env {
  Env._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', 
  );

  static const String webBaseUrl = String.fromEnvironment(
    'BASE_URL',
    // Change the default value below to your actual Host IP!
    defaultValue: 'http://127.0.0.1:8000/api/v1', // <-- FIX: Use Host IP
  );
}