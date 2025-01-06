
enum ResponseStatus {
  success,
  failed,

}

class ResponseResult {
  final ResponseStatus status;
  final String message;
  final Map<String, dynamic>? data;

  ResponseResult({
    required this.status,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}
