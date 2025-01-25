import 'dart:io';

import 'package:interact/interact.dart';

enum OperationType { specificFile, specificFolder, entireProject }

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

class DirectorySelector {
  OperationType selectOperation() {
    final choiceIndex = Select(
      prompt: 'Choose an operation:',
      options: OperationType.values.map((type) => type.name).toList(),
      initialIndex: 0,
    ).interact();

    switch (choiceIndex) {
      case 0:
        return OperationType.specificFile;
      case 1:
        return OperationType.specificFolder;
      case 2:
        return OperationType.entireProject;
      default:
        throw Exception('Invalid operation selected.');
    }
  }

  String selectPath({required bool showFiles}) {
    while (true) {
      final currentDir = Directory.current;
      final entries = currentDir
          .listSync()
          .where((entity) => showFiles ? true : entity is Directory)
          .map((entity) => entity.path.split(Platform.pathSeparator).last)
          .toList();

      if (entries.isEmpty) {
        print(
            '❌ No ${showFiles ? "files or folders" : "folders"} found in the current directory.');
        exit(1);
      }

      final selectedIndex = Select(
        prompt: 'Choose ${showFiles ? "a file or folder" : "a folder"}:',
        options: entries,
      ).interact();

      final selectedPath = '${currentDir.path}/${entries[selectedIndex]}';

      if (showFiles && File(selectedPath).existsSync()) {
        return selectedPath; // File valid
      } else if (!showFiles && Directory(selectedPath).existsSync()) {
        return selectedPath; // Folder valid
      } else {
        print('❌ Invalid selection. Please try again.');
      }
    }
  }
}
