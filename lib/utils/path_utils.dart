import 'dart:io';

class PathUtils {
  static bool isValidDirectory(String path) {
    final directory = Directory(path);
    return directory.existsSync();
  }
}
