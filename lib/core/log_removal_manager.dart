import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:log_removal/core/directory_selector.dart';
import 'package:log_removal/core/log_cleaner.dart';
import 'package:log_removal/models/pattern.dart';

/// A class responsible for managing the log removal process.
/// This includes selecting the operation type (folder/file), choosing log patterns,
/// and performing the log removal on the specified target path.
///
/// Example usage:
/// ```dart
/// final logRemovalManager = LogRemovalManager(directorySelector);
/// logRemovalManager.run();
/// ```
class LogRemovalManager {
  final console =
      Console(); // Console instance for user interaction and colored output
  final DirectorySelector
      directorySelector; // Instance used for selecting directory or files
  late final String
      targetPath; // The target path where the logs will be removed from
  final List<LogPattern> defaultPatterns = [
    LogPattern(name: 'print() statements', pattern: 'print\(.*\);'),
    LogPattern(name: 'debugPrint() statements', pattern: 'debugPrint\(.*\);'),
    LogPattern(name: 'log() statements', pattern: 'log\(.*\);'),
    LogPattern(name: 'logger() statements', pattern: 'logger\(.*\);'),
  ]; // Default patterns for common log statements

  /// Constructor for initializing `LogRemovalManager` with a given [directorySelector].
  ///
  /// [directorySelector] is used to manage the directory or file selection for the operation.
  LogRemovalManager(this.directorySelector);

  /// Starts the log removal process, which includes selecting the operation type,
  /// specifying the target path, and choosing the log patterns to remove.
  ///
  /// The method runs asynchronously and displays a progress bar while cleaning the logs.
  Future<void> run() async {
    console.setForegroundColor(
        ConsoleColor.brightBlue); // Set console color for the message
    final operationType =
        directorySelector.selectOperation(); // Select operation type
    targetPath =
        directorySelector.selectTargetPath(operationType); // Select target path

    final patterns =
        selectLogPatterns(); // Get the log patterns selected by the user
    final logCleaner =
        LogCleaner(targetPath, patterns); // Create the LogCleaner instance

    console.setForegroundColor(
        ConsoleColor.cyan); // Set console color for the next message
    print('\nStarting log removal process...'); // Notify user of process start

    // Perform log cleaning and wait for result
    final result = await logCleaner.cleanLogs();

    console.setForegroundColor(
        ConsoleColor.cyan); // Set console color for result message
    print('\n✅ ${result.message}'); // Display the result message
    print(
        '📁 Files Processed: ${result.filesProcessed}'); // Show the number of files processed

    // Display the cleaned files or a message that no logs were found
    if (result.cleanedFiles.isEmpty) {
      console.setForegroundColor(ConsoleColor.brightBlue);
      print('🎉 All clean! No unwanted logs found.');
    } else {
      console.setForegroundColor(ConsoleColor.magenta);
      print('📝 Cleaned Files:');
      for (var file in result.cleanedFiles) {
        print('- ${file.path}'); // Print the cleaned files
      }
    }
  }

  /// Selects and returns a list of regular expression patterns used for log removal.
  ///
  /// This method is responsible for providing the patterns that will be used
  /// to identify and remove log entries from the application logs.
  ///
  /// Returns:
  ///   A list of [RegExp] objects representing the log patterns to be removed.
  List<RegExp> selectLogPatterns() {
    while (true) {
      console.setForegroundColor(ConsoleColor.brightBlue);
      print('\n🔧 Choose log patterns to remove:');
      final multiSelect = MultiSelect(
        prompt:
            '✨ Select the log patterns you want to remove: (use space to toggle)',
        options: defaultPatterns.map((pattern) => pattern.name).toList()
          ..add(
              'Custom Log Name 🔍'), // Tambahkan opsi untuk memasukkan nama log custom
      ).interact();

      final selectedPatterns = <RegExp>[];
      for (final index in multiSelect) {
        if (index < defaultPatterns.length) {
          selectedPatterns
              .add(defaultPatterns[index].pattern); // Tambahkan pola default
          console.setForegroundColor(ConsoleColor.green);
          print('✅ Added: ${defaultPatterns[index].name}');
        } else {
          final customPattern = _getCustomPattern(); // Dapatkan pola custom
          selectedPatterns.add(customPattern); // Tambahkan pola custom
        }
      }

      if (selectedPatterns.isEmpty) {
        console.setForegroundColor(ConsoleColor.red);
        print('\n❌ You must select at least one log pattern!');
        console.setForegroundColor(ConsoleColor.yellow);
        print('🔁 Returning to log pattern selection...\n');
      } else {
        console.resetColorAttributes();
        return selectedPatterns; // Kembalikan daftar pola yang dipilih
      }
    }
  }

  /// Converts a log name (e.g., "print") to a regex pattern (e.g., "print\(.*\);").
  ///
  /// This method takes a log name as input and returns a regular expression
  /// that matches the log statement with any arguments.
  ///
  /// - Parameter logName: The name of the log function to be converted.
  /// - Returns: A `RegExp` object that matches the log statement.
  /// Mengonversi nama log (misalnya, "print") menjadi regex (misalnya, "print\(.*\);")
  RegExp _convertLogNameToRegex(String logName) {
    return RegExp('$logName\\(.*\\);');
  }

  /// Prompts the user to enter a custom log pattern (regular expression).
  ///
  /// This method ensures the custom pattern is valid before adding it to the selected patterns.
  /// If the pattern is invalid or empty, the user is prompted to enter it again.
  ///
  /// Returns a valid RegExp object for the custom pattern.
  /// Meminta pengguna memasukkan nama log (bukan regex) dan mengonversinya ke regex
  RegExp _getCustomPattern() {
    while (true) {
      console.resetColorAttributes();
      print(
          '\n🔧 Enter the name of the log function (e.g., print, debugPrint, console.log):');
      final logName = Input(
        prompt: 'Enter Log Name:',
        validator: (input) {
          return input.isNotEmpty && !input.contains(RegExp(r'[^\w\.]'));
        },
      ).interact();

      try {
        final customPattern =
            _convertLogNameToRegex(logName); // Konversi nama log ke regex
        console.setForegroundColor(ConsoleColor.green);
        print('✅ Custom log pattern added successfully!');
        return customPattern; // Kembalikan regex yang dihasilkan
      } catch (e) {
        console.setForegroundColor(ConsoleColor.red);
        print('❌ Error creating regex: $e'); // Tangani error jika terjadi
        console.setForegroundColor(ConsoleColor.yellow);
        print('🔁 Please try again with a valid log name.\n');
      }
    }
  }
}
