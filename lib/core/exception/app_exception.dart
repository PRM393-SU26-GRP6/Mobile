class AppException implements Exception {
  final String message;
  final String? code;
  final String? details;

  AppException({required this.message, this.code, this.details});
}