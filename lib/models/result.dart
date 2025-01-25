class Result {
  final bool success;
  final String message;
  final int filesProcessed;

  Result({
    required this.success,
    required this.message,
    this.filesProcessed = 0,
  });
}
