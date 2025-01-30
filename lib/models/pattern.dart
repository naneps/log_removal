/// A class representing a log pattern with a name and a regular expression pattern.
///
/// The [LogPattern] class is used to define a pattern for log entries. It contains
/// a name for the pattern and a regular expression to match log entries.
///
/// Example usage:
/// ```dart
/// final logPattern = LogPattern(name: 'Error', pattern: r'ERROR: .*');
/// ```
///
/// Properties:
/// - `name`: The name of the log pattern.
/// - `pattern`: The regular expression pattern used to match log entries.
///
/// Constructor:
/// - `LogPattern({required String name, required String pattern})`:
///   Creates a new [LogPattern] instance with the given name and pattern.
class LogPattern {
  final String name;
  RegExp? pattern;

  LogPattern({required this.name, required String pattern}) {
    this.pattern = RegExp(pattern);
  }
}
