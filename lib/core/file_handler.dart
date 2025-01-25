import 'dart:io';

class FileHandler {
  static List<File> getDartFiles(Directory directory) {
    return directory
        .listSync(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();
  }
}
