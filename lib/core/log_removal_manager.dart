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
  /// A regular expression pattern used to match and remove log statements
  /// that contain parentheses and end with a semicolon.
  ///
  /// This pattern matches any whitespace characters followed by an opening
  /// parenthesis, any characters inside the parentheses, and any whitespace
  /// characters followed by a semicolon.
  ///
  /// Example:
  /// ```dart
  /// // Matches:
  /// // log("This is a log statement");
  /// // log("Another log statement");
  ///
  /// // Does not match:
  /// // print("This is not a log statement");
  /// ```
  static final _regexPatterns = r'\s*\(.*\)\s*;';

  /// Console instance for user interaction and colored output
  final console = Console();

  ///  Instance used for selecting directory or files
  final DirectorySelector directorySelector;

  /// The path to the target directory or file that will be managed by the log removal process.
  late final String targetPath;

  /// A list of default log patterns to be removed from the code.
  ///
  /// This list contains instances of [LogPattern] that match common logging
  /// statements such as `print()`, `debugPrint()`, `log()`, and `logger()`.
  /// Each pattern is combined with a predefined set of regular expression
  /// patterns stored in [_regexPatterns].
  ///
  /// - `print() statements`: Matches `print` statements.
  /// - `debugPrint() statements`: Matches `debugPrint` statements.
  /// - `log() statements`: Matches `log` statements.
  /// - `logger() statements`: Matches `logger` statements.
  final List<LogPattern> defaultPatterns = [
    LogPattern(
        name: 'print() statements', pattern: r'\bprint' + _regexPatterns),
    LogPattern(
        name: 'debugPrint() statements',
        pattern: r'\bdebugPrint' + _regexPatterns),
    LogPattern(name: 'log() statements', pattern: r'\blog' + _regexPatterns),
    LogPattern(
        name: 'logger() statements', pattern: r'\blogger' + _regexPatterns),
  ];

  LogRemovalManager(this.directorySelector);

  /// Runs the log removal process.
  ///
  /// This method sets the console text color, selects the operation type and target path,
  /// selects log patterns, and initializes the log cleaner. It then starts the log removal
  /// process and prints the result, including the number of files processed and the list of
  /// cleaned files, if any.
  ///
  /// The console text color is changed to indicate different stages of the process.
  ///
  /// Throws an exception if the log removal process fails.
  Future<void> run() async {
    console.setForegroundColor(ConsoleColor.brightBlue);
    final operationType = directorySelector.selectOperation();
    targetPath = directorySelector.selectTargetPath(operationType);

    final patterns = selectLogPatterns();
    final logCleaner = LogCleaner(targetPath, patterns);

    console.setForegroundColor(ConsoleColor.cyan);
    print('\nStarting log removal process...');

    final result = await logCleaner.cleanLogs();
    if (result.success) {
      console.setForegroundColor(ConsoleColor.cyan);
      print('\n✅ ${result.message}');
      print('📁 Files Processed: ${result.filesProcessed}');

      if (result.cleanedFiles.isEmpty) {
        console.setForegroundColor(ConsoleColor.brightBlue);
        print('🎉 All clean! No unwanted logs found.');
      } else {
        console.setForegroundColor(ConsoleColor.magenta);
        print('📝 Cleaned Files:');
        for (var file in result.cleanedFiles) {
          print('- ${file.path}');
        }
      }
    } else {
      console.setForegroundColor(ConsoleColor.brightRed);
      print('❌ ${result.message}');
      throw Exception('Log removal process failed: ${result.message}');
    }

    console.resetColorAttributes();
  }

  /// Prompts the user to select log patterns to remove from a list of default patterns
  /// or to input a custom log pattern. The user can toggle selections using the space key.
  ///
  /// The method will continue to prompt the user until at least one log pattern is selected.
  ///
  /// Returns a list of selected [RegExp] patterns.
  ///
  /// - If a default pattern is selected, it is added to the list of selected patterns.
  /// - If the custom log name option is selected, the user is prompted to input a custom pattern,
  ///   which is then added to the list of selected patterns.
  ///
  /// The method provides visual feedback in the console using different colors:
  /// - Blue for the initial prompt
  /// - Green for confirming a pattern has been added
  /// - Red for indicating that no patterns were selected
  /// - Yellow for indicating that the selection process will restart
  List<RegExp> selectLogPatterns() {
    while (true) {
      console.setForegroundColor(ConsoleColor.brightBlue);
      print('\n🔧 Choose log patterns to remove:');
      final multiSelect = MultiSelect(
        prompt:
            '✨ Select the log patterns you want to remove: (use space to toggle)',
        options: defaultPatterns.map((pattern) => pattern.name).toList()
          ..add('Custom Log Name 🔍'),
      ).interact();

      final selectedPatterns = <RegExp>[];
      for (final index in multiSelect) {
        if (index < defaultPatterns.length) {
          selectedPatterns.add(defaultPatterns[index].pattern!);
          console.setForegroundColor(ConsoleColor.green);
          print('✅ Added: ${defaultPatterns[index].name}');
        } else {
          final customPattern = _getCustomPattern();
          selectedPatterns.add(customPattern);
        }
      }

      if (selectedPatterns.isEmpty) {
        console.setForegroundColor(ConsoleColor.red);
        print('\n❌ You must select at least one log pattern!');
        console.setForegroundColor(ConsoleColor.yellow);
        print('🔁 Returning to log pattern selection...\n');
      } else {
        console.resetColorAttributes();
        return selectedPatterns;
      }
    }
  }

  /// Converts a log name to a regular expression pattern.
  ///
  /// The log name must consist of only alphanumeric characters. If the log
  /// name contains any non-alphanumeric characters, an [ArgumentError] is
  /// thrown.
  ///
  /// The returned regular expression matches the log name followed by an
  /// optional whitespace, an opening parenthesis, any characters inside the
  /// parentheses, a closing parenthesis, optional whitespace, and a semicolon.
  ///
  /// Example:
  /// ```
  /// final regex = _convertLogNameToRegex('logName');
  /// print(regex.hasMatch('logName(param1, param2);')); // true
  /// ```
  ///
  /// [logName] The name of the log to be converted to a regular expression.
  /// Returns a [RegExp] object that matches the specified log name pattern.

  RegExp _convertLogNameToRegex(String logName) {
    if (!RegExp(r'^\w+$').hasMatch(logName)) {
      throw ArgumentError(
          'Invalid log name. Only alphanumeric characters are allowed.');
    }
    final pattern = r'\b' + logName + r'\s*\(.*\)\s*;';
    print("🔧 Converted log name => '$logName' to pattern: '$pattern'");
    return RegExp(pattern);
  }

  /// Prompts the user to enter the name of a log function and converts it to a regular expression pattern.
  ///
  /// This method continuously prompts the user to input a valid log function name until a valid name is provided.
  /// It validates the input to ensure it contains only word characters and dots. If the input is valid, it converts
  /// the log function name to a regular expression pattern and returns it. If an error occurs during the conversion,
  /// it displays an error message and prompts the user to try again.
  ///
  /// Returns:
  ///   A [RegExp] object representing the custom log pattern.
  ///
  /// Throws:
  ///   An exception if the log function name cannot be converted to a regular expression pattern.

  RegExp _getCustomPattern() {
    while (true) {
      console.resetColorAttributes();
      print(
          '\n🔧 Enter the name of the log function (e.g., print, debugPrint, console.log):');
      final logName = Input(
        prompt: 'Enter Log Name:',
        validator: (input) {
          return input.isNotEmpty;
        },
      ).interact();

      try {
        final customPattern = _convertLogNameToRegex(logName);
        console.setForegroundColor(ConsoleColor.green);
        print('✅ Custom log pattern added successfully!');
        return customPattern;
      } catch (e) {
        console.setForegroundColor(ConsoleColor.red);
        print('❌ Error creating regex: $e');
        console.setForegroundColor(ConsoleColor.yellow);
        print('🔁 Please try again with a valid log name.\n');
      }
    }
  }
}
