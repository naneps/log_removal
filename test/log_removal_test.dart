import 'dart:io';
import 'package:test/test.dart';
import 'package:log_removal/core/log_cleaner.dart';

void main() {
  group('LogCleaner Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('log_removal_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    File _createFile(String fileName, String content) {
      final file = File('${tempDir.path}/$fileName');
      file.writeAsStringSync(content);
      return file;
    }

    test('should remove simple print statements', () {
      final content = '''
void main() {
  print('Hello World');
  print("Another one");
  int x = 10;
}
''';
      final file = _createFile('test.dart', content);
      final logPatterns = [RegExp(r'\bprint\s*\([\s\S]*?\)\s*;', dotAll: true)];
      
      final cleaner = LogCleaner(tempDir.path, logPatterns);
      final result = cleaner.cleanLogs();

      expect(result.success, isTrue);
      expect(result.filesProcessed, 1);
      
      final cleanedContent = file.readAsStringSync();
      expect(cleanedContent, contains('void main() {'));
      expect(cleanedContent, contains('int x = 10;'));
      expect(cleanedContent, isNot(contains('print(')));
    });

    test('should only remove matched text if other code exists on the same line', () {
      final content = '''
void main() {
  if (true) print('debug'); doSomething();
}
''';
      final file = _createFile('test_same_line.dart', content);
      final logPatterns = [RegExp(r'\bprint\s*\([\s\S]*?\)\s*;', dotAll: true)];
      
      final cleaner = LogCleaner(tempDir.path, logPatterns);
      cleaner.cleanLogs();

      final cleanedContent = file.readAsStringSync();
      expect(cleanedContent, contains('if (true)  doSomething();'));
      expect(cleanedContent, isNot(contains('print(')));
    });

    test('should remove multi-line log statements', () {
      final content = '''
void main() {
  print(
    'Multi-line'
    'log statement'
  );
  int y = 20;
}
''';
      final file = _createFile('test_multi_line.dart', content);
      final logPatterns = [RegExp(r'\bprint\s*\([\s\S]*?\)\s*;', dotAll: true)];
      
      final cleaner = LogCleaner(tempDir.path, logPatterns);
      cleaner.cleanLogs();

      final cleanedContent = file.readAsStringSync();
      expect(cleanedContent, contains('void main() {'));
      expect(cleanedContent, contains('int y = 20;'));
      expect(cleanedContent, isNot(contains('Multi-line')));
    });

    test('should support custom log names', () {
      final content = '''
void main() {
  myCustomLog('Important info');
  print('Normal print');
}
''';
      _createFile('test_custom.dart', content);
      final logPatterns = [
        RegExp(r'\bmyCustomLog\s*\([\s\S]*?\)\s*;', dotAll: true)
      ];
      
      final cleaner = LogCleaner(tempDir.path, logPatterns);
      final result = cleaner.cleanLogs();

      expect(result.filesProcessed, 1);
      final cleanedContent = File('${tempDir.path}/test_custom.dart').readAsStringSync();
      expect(cleanedContent, contains("print('Normal print')"));
      expect(cleanedContent, isNot(contains('myCustomLog')));
    });
  });
}
