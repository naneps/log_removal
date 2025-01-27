import 'dart:io';

/// A class representing the result of a log removal operation.
class LogRemovalResult {
  final bool success;
  final String message;
  final int filesProcessed;
  final List<File> cleanedFiles; // Menyimpan file-file yang telah dibersihkan

  LogRemovalResult({
    required this.success,
    required this.message,
    required this.filesProcessed,
    required this.cleanedFiles,
  });
}
