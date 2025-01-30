import 'dart:io';

/// A utility class for handling file system paths.
class PathUtils {
  /// Checks if the given [path] is a valid directory.
  ///
  /// Returns `true` if the directory exists, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// bool isValid = PathUtils.isValidDirectory('/path/to/directory');
  /// ```
  static bool isValidDirectory(String path) {
    final directory = Directory(path);
    return directory.existsSync();
  }
}
