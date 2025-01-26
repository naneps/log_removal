import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:log_removal/core/directory_selector.dart';
import 'package:log_removal/core/log_cleaner.dart';
import 'package:log_removal/models/pattern.dart';

class LogRemovalManager {
  final console = Console();
  final DirectorySelector directorySelector;
  late final String targetPath;
  final List<LogPattern> defaultPatterns = [
    LogPattern(name: 'print() statements', pattern: 'print'),
    LogPattern(name: 'debugPrint() statements', pattern: 'debugPrint\(.*\);'),
    LogPattern(name: 'log() statements', pattern: 'log\(.*\);'),
    LogPattern(name: 'logger() statements', pattern: 'logger\(.*\);'),
  ];

  LogRemovalManager(this.directorySelector);

  void run() {
    console.setForegroundColor(ConsoleColor.brightBlue);
    final operationType = directorySelector.selectOperation();
    targetPath = directorySelector.selectTargetPath(operationType);

    final patterns = selectLogPatterns();

    final logCleaner = LogCleaner(targetPath, patterns);
    final result = logCleaner.cleanLogs();

    console.setForegroundColor(ConsoleColor.cyan);
    print('\n✅ ${result.message}');
    print('📁 Files Processed: ${result.filesProcessed}');

    if (result.cleanedFiles.isEmpty) {
      console.setForegroundColor(ConsoleColor.brightBlue);
      print(
          '🎉 All clean! The selected folder or files are already free of unwanted logs. 🚀');
    } else {
      console.setForegroundColor(ConsoleColor.magenta);
      print('📝 Cleaned Files:');
      for (var file in result.cleanedFiles) {
        print('- ${file.path}');
      }
    }
  }

  List<RegExp> selectLogPatterns() {
    while (true) {
      // Loop hingga pengguna memilih minimal satu pola
      console.setForegroundColor(ConsoleColor.brightBlue);
      print('\n🔧 Choose log patterns to remove:');
      final multiSelect = MultiSelect(
        prompt:
            '✨ Select the log patterns you want to remove: (use space to toggle)',
        options: defaultPatterns.map((pattern) => pattern.name).toList()
          ..add('Custom Pattern 🔍'),
      ).interact();

      final selectedPatterns = <RegExp>[];
      for (final index in multiSelect) {
        if (index < defaultPatterns.length) {
          selectedPatterns.add(defaultPatterns[index].pattern);
          console.setForegroundColor(ConsoleColor.green);
          print('✅ Added: ${defaultPatterns[index].name}');
        } else {
          // Proses untuk custom pattern
          while (true) {
            console.resetColorAttributes();
            print('\n🔧 Enter your custom log pattern (Regex):');
            print('📝 Example: loggerInfo or log\\(.*\\);');
            final customPatternInput = Input(
              prompt: 'Enter Regex Pattern:',
              validator: (input) => input.isEmpty,
            ).interact();

            if (customPatternInput.isEmpty) {
              console.setForegroundColor(ConsoleColor.red);
              print('❌ Custom pattern cannot be empty. Please try again.');
            } else {
              try {
                final customPattern = RegExp(customPatternInput);
                selectedPatterns.add(customPattern);
                console.setForegroundColor(ConsoleColor.green);
                print('✅ Custom pattern added successfully!');
                break; // Keluar dari loop custom pattern jika berhasil
              } catch (e) {
                console.setForegroundColor(ConsoleColor.red);
                print('❌ Invalid regex pattern: $e');
              }
            }
          }
        }
      }

      if (selectedPatterns.isEmpty) {
        console.setForegroundColor(ConsoleColor.red);
        print('\n❌ You must select at least one log pattern!');
        console.setForegroundColor(ConsoleColor.yellow);
        print('🔁 Returning to log pattern selection...\n');
      } else {
        console.resetColorAttributes();
        return selectedPatterns; // Return jika ada pola yang dipilih
      }
    }
  }
}
