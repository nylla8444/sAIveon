class ApiError {
  final String message;
  final int? statusCode;

  ApiError(this.message, {this.statusCode});
}
