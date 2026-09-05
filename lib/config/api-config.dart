import 'dart:io' show Platform;

class ApiConfig {
  ApiConfig._();

  /// Override the backend URL at build/run time, e.g.:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the Spring Boot backend (no trailing slash).
  ///
  /// The Android emulator can't reach the host machine via `localhost`, so
  /// it needs the special alias `10.0.2.2` instead. iOS simulators and
  /// desktop can reach the host machine directly.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

}
