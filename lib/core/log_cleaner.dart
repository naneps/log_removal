import 'dart:io';

import 'package:log_removal/models/result.dart';

class LogCleaner {
  final String directoryPath;
  final List<RegExp> logPatterns;

  LogCleaner(this.directoryPath, this.logPatterns);

  LogRemovalResult cleanLogs() {
    if (!Directory(directoryPath).existsSync()) {
      throw Exception('Invalid directory: $directoryPath');
    }

    final dartFiles = _getDartFiles();
    final cleanedFiles = _processFiles(dartFiles);

    return LogRemovalResult(
      success: true,
      message: 'Log removal completed successfully.',
      filesProcessed: cleanedFiles.length,
      cleanedFiles:
          cleanedFiles, // Menyimpan daftar file yang telah dibersihkan
    );
  }

  List<File> _getDartFiles() {
    return Directory(directoryPath)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }

  List<File> _processFiles(List<File> files) {
    final cleanedFiles = <File>[];

    for (final file in files) {
      final lines = file.readAsLinesSync();
      final updatedLines = lines
          .where(
              (line) => !logPatterns.any((pattern) => pattern.hasMatch(line)))
          .toList();

      if (updatedLines.length != lines.length) {
        file.writeAsStringSync(updatedLines.join('\n'));
        cleanedFiles.add(
            file); // Menambahkan file ke daftar cleanedFiles jika ada perubahan
      }
    }

    return cleanedFiles;
  }
}
