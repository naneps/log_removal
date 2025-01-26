import 'dart:io';

/// A utility class for handling file operations.
///
/// The `FileHandler` class provides methods for interacting with files in
/// a given directory. Specifically, it can retrieve all Dart files (`.dart`)
/// in the directory and its subdirectories.
///
/// Example usage:
/// ```dart
/// final dartFiles = FileHandler.getDartFiles(Directory('path/to/directory'));
/// print(dartFiles);
/// ```
class FileHandler {
  /// Retrieves all Dart files from a given directory.
  ///
  /// This method scans the specified directory and its subdirectories
  /// for all `.dart` files and returns them as a list of `File` objects.
  ///
  /// [directory] The directory to scan for Dart files.
  ///
  /// Returns a list of `File` objects representing all Dart files in the directory.
  static List<File> getDartFiles(Directory directory) {
    return directory
        .listSync(
            recursive: true) // Recursively lists all files in the directory
        .where((entity) =>
            entity is File &&
            entity.path.endsWith('.dart')) // Filters out non-Dart files
        .cast<File>() // Casts the entity to a File type
        .toList(); // Converts to a list and returns it
  }
}
