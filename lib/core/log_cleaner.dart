import 'dart:io';

import 'package:log_removal/models/result.dart';
import 'package:log_removal/utils/path_utils.dart';

/// A class responsible for cleaning logs in Dart files.
///
/// The `LogCleaner` class processes files in a specified directory, identifies
/// log patterns, and removes lines matching those patterns. It handles
/// recursively searching for Dart files and cleaning them based on the patterns
/// provided.
///
/// Example usage:
/// ```dart
/// final logCleaner = LogCleaner('path/to/directory', [RegExp('log\\(.*\\);')]);
/// final result = logCleaner.cleanLogs();
/// print(result.message);
/// ```
class LogCleaner {
  final String directoryPath; // The path to the directory containing Dart files
  final List<RegExp> logPatterns; // List of patterns to match log statements

  /// Constructor for initializing the `LogCleaner` with a directory path and
  /// log patterns.
  ///
  /// [directoryPath] The directory to scan for Dart files.
  /// [logPatterns] A list of regular expressions used to identify log statements.
  LogCleaner(this.directoryPath, this.logPatterns);

  /// Cleans logs from Dart files in the specified directory.
  ///
  /// This method processes all Dart files within the provided directory and
  /// removes lines that match any of the provided log patterns. It returns a
  /// `LogRemovalResult` that contains information about the files that were
  /// processed and cleaned.
  ///
  /// Returns a `LogRemovalResult` containing the outcome of the cleaning process.
  LogRemovalResult cleanLogs() {
    if (!PathUtils.isValidDirectory(directoryPath)) {
      return LogRemovalResult(
        success: false,
        message: 'Invalid directory path: $directoryPath',
        filesProcessed: 0,
        cleanedFiles: [],
      );
    }

    final dartFiles = _getDartFiles(); // Get all Dart files in the directory
    final cleanedFiles = _processFiles(dartFiles); // Process and clean files

    return LogRemovalResult(
      success: true,
      message: 'Log removal completed successfully.',
      filesProcessed: cleanedFiles.length,
      cleanedFiles: cleanedFiles, // List of cleaned files
    );
  }

  /// Retrieves all Dart files from the specified directory.
  ///
  /// This method scans the directory recursively and returns a list of Dart
  /// files (`.dart`) found within it.
  ///
  /// Returns a list of `File` objects representing Dart files.
  List<File> _getDartFiles() {
    return Directory(directoryPath)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')) // Filter only Dart files
        .toList();
  }

  /// Processes a list of Dart files, removing lines matching the log patterns.
  ///
  /// This method reads each Dart file, checks each line against the log patterns,
  /// and removes any lines that match. The cleaned file is saved if any lines
  /// were removed.
  ///
  /// [files] A list of `File` objects representing Dart files to process.
  ///
  /// Returns a list of `File` objects that were cleaned.
  List<File> _processFiles(List<File> files) {
    final cleanedFiles = <File>[]; // List to store cleaned files

    for (final file in files) {
      final lines = file.readAsLinesSync(); // Read file lines
      print('🔧 Processing file: ${file.path}');
      print('🔧 Number of lines: ${lines.length}');
      final updatedLines = lines
          .where(
            (line) => !logPatterns.any(
              (pattern) => pattern.hasMatch(line),
            ),
          ) // Filter out lines matching log patterns
          .toList();
      print('🔧 Number of lines after cleaning: ${updatedLines.length}');

      if (updatedLines.length != lines.length) {
        file.writeAsStringSync(
            updatedLines.join('\n')); // Save the cleaned file
        cleanedFiles.add(file); // Add file to cleanedFiles if changes were made
      }
    }

    return cleanedFiles; // Return the list of cleaned files
  }
}
