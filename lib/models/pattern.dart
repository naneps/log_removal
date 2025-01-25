class LogPattern {
  final String name;
  late final RegExp pattern;

  LogPattern({required this.name, required String pattern}) {
    this.pattern = RegExp(pattern);
  }
}
