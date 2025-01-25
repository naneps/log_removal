import 'dart:io';

class LogCleaner {
  final List<RegExp> logPatterns;

  LogCleaner(this.logPatterns);

  /// Clean logs from the given list of Dart files.
  static List<File> cleanLogs(List<File> files, List<RegExp> patterns) {
    final cleanedFiles = <File>[];

    for (final file in files) {
      final lines = file.readAsLinesSync();

      // Remove lines that match any of the provided patterns
      final updatedLines = lines.where((line) {
        return !patterns.any((pattern) => pattern.hasMatch(line));
      }).toList();

      // If any changes were made, overwrite the file
      if (updatedLines.length != lines.length) {
        file.writeAsStringSync(updatedLines.join('\n'));
        cleanedFiles.add(file); // Add to the cleaned files list
      }
    }

    return cleanedFiles;
  }
}
