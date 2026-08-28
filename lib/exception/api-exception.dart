class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when a session can't be established or restored (missing/expired
/// refresh token, refresh rejected by the server). Callers should route the
/// user back to the login screen.
class UnauthenticatedException extends ApiException {
  UnauthenticatedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}
