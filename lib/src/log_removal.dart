import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: remove_print <path>');
    return;
  }

  final path = arguments[0];
  final directory = Directory(path);

  if (!directory.existsSync()) {
    print('Error: Directory does not exist.');
    return;
  }

  print('Scanning directory: $path');

  final dartFiles = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (var file in dartFiles) {
    _removePrintStatements(file);
  }

  print('All print() statements removed!');
}

void _removePrintStatements(File file) {
  final content = file.readAsStringSync();
  final newContent =
      content.replaceAll(RegExp(r'print\(.*?\);'), ''); // Hapus print()
  if (content != newContent) {
    file.writeAsStringSync(newContent);
    print('Updated: ${file.path}');
  }
}
