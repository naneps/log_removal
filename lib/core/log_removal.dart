import 'dart:io';

import 'package:log_removal/core/file_handler.dart';
import 'package:log_removal/core/log_cleaner.dart';
import 'package:log_removal/models/result.dart';
import 'package:log_removal/utils/path_utils.dart';

class LogRemoval {
  final String directoryPath;
  final List<RegExp> logPatterns;

  LogRemoval(this.directoryPath, {required this.logPatterns});

  Result run() {
    // Validate directory path
    if (!PathUtils.isValidDirectory(directoryPath)) {
      return Result(success: false, message: 'Invalid directory.');
    }

    // Get all Dart files in the directory
    final files = FileHandler.getDartFiles(Directory(directoryPath));

    // Clean logs using the specified patterns
    final cleanedFiles = LogCleaner.cleanLogs(files, logPatterns);

    // Return result
    return Result(
      success: true,
      message: 'Log removal completed.',
      filesProcessed: cleanedFiles.length,
    );
  }
}
