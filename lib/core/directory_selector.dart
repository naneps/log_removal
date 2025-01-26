import 'dart:io';

import 'package:interact/interact.dart';

enum OperationType {
  entireProject,
  specificFile,
  specificFolder,
}

extension OperationTypeExtension on OperationType {
  String get name {
    switch (this) {
      case OperationType.specificFile:
        return 'Specific File';
      case OperationType.specificFolder:
        return 'Specific Folder';
      case OperationType.entireProject:
        return 'Entire Project';
    }
  }
}

/// A class that provides functionality for selecting directories.
///
/// This class can be used to open a directory picker dialog and retrieve
/// the selected directory path.
class DirectorySelector {
  OperationType selectOperation() {
    final choiceIndex = Select(
      prompt: 'Choose an operation:',
      options: OperationType.values.map((type) => type.name).toList(),
    ).interact();

    return OperationType.values[choiceIndex];
  }

  String selectTargetPath(OperationType operationType) {
    switch (operationType) {
      case OperationType.specificFile:
        return selectSpecificFiles();
      case OperationType.specificFolder:
        return selectFolderPath();
      case OperationType.entireProject:
        return confirmEntireProject();
      default:
        throw Exception('Invalid operation selected.');
    }
  }

  // Method to select specific files grouped by path
  /// Selects specific files from a directory.
  ///
  /// This method allows the user to select specific files based on certain criteria.
  ///
  /// Returns a [String] representing the selected files.
  String selectSpecificFiles() {
    final currentDir = Directory.current;

    final filesByPath = <String, List<String>>{};
    currentDir
        .listSync(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .forEach((file) {
      final dirPath = Directory(file.parent.path).path;
      if (!filesByPath.containsKey(dirPath)) {
        filesByPath[dirPath] = [];
      }
      filesByPath[dirPath]?.add(file.path);
    });

    if (filesByPath.isEmpty) {
      exit(1);
    }

    // Display grouped files by path
    final groupedEntries = <String>[];
    filesByPath.forEach((dir, files) {
      groupedEntries.add('📁 $dir');
      groupedEntries.addAll(files.map((file) => '  - $file').toList());
    });

    final selectedIndex = Select(
      prompt: 'Choose a Dart file:',
      options: groupedEntries,
    ).interact();

    final selectedPath = groupedEntries[selectedIndex];
    if (selectedPath.startsWith('  - ')) {
      return selectedPath.substring(4); // Return file path
    } else {
      exit(1);
    }
  }

  String confirmEntireProject() {
    final confirmation = Confirm(
      prompt: 'Are you sure you want to select the entire project?',
      defaultValue: false,
    ).interact();

    if (confirmation) {
      return Directory.current.path; // Return entire project path
    } else {
      exit(1);
    }
  }

  // Updated method to allow selecting folders without adding folder name prefix
  /// Selects a folder path.
  ///
  /// This function allows the user to select a folder path from the file system.
  ///
  /// Returns:
  ///   A [String] representing the selected folder path.
  String selectFolderPath() {
    String currentDir = Directory.current.path;

    while (true) {
      final entries = Directory(currentDir)
          .listSync()
          .where((entity) =>
              entity is Directory &&
              !entity.path
                  .split(Platform.pathSeparator)
                  .last
                  .startsWith('.')) // Exclude hidden folders
          .map((entity) => entity.path.split(Platform.pathSeparator).last)
          .toList();

      if (entries.isEmpty) {
        exit(1);
      }

      // Display folder options in a cleaner format
      final selectedIndex = Select(
        prompt: 'Choose a folder:',
        options: [
          ...entries,
          '.. (Go back)' // Add '..' option to go up one level
        ],
      ).interact();

      if (selectedIndex == entries.length) {
        // Going up one level
        if (Directory(currentDir).parent.path == currentDir) {
          continue;
        }
        currentDir = Directory(currentDir).parent.path;
      } else {
        final selectedFolder = entries[selectedIndex];
        final selectedFolderPath =
            '$currentDir$Platform.pathSeparator$selectedFolder';

        // If the user selects a folder, go into that folder
        if (Directory(selectedFolderPath).existsSync()) {
          currentDir = selectedFolderPath;
        }
      }

      // When a valid folder is selected
      if (Directory(currentDir).existsSync()) {
        return currentDir;
      } else {}
    }
  }
}
