import 'package:dart_console/dart_console.dart';
import 'package:log_removal/core/directory_selector.dart';
import 'package:log_removal/core/log_removal_manager.dart';

final console = Console();

void main() {
  // Clear the screen
  console.clearScreen();

  // Set a gradient-like effect using alternating colors
  console.setForegroundColor(ConsoleColor.cyan);
  console.writeLine("========================================");

  // Center the welcome message with some padding
  console.setForegroundColor(ConsoleColor.brightBlue);
  String welcomeText = "🔧✨  WELCOME TO LOG REMOVAL CLI! ✨🔧";
  int padding = (40 - welcomeText.length) ~/ 2; // Adjust padding for centering
  console.writeLine(" " * padding + welcomeText);

  console.setForegroundColor(ConsoleColor.cyan);
  console.writeLine("========================================\n");

// Add a friendly, motivational introduction
  console.setForegroundColor(ConsoleColor.green);
  console.writeLine('👋 Hey there, friend!');
  console
      .writeLine('Ready to tidy up your code and banish those pesky logs? 🧹');
  console.writeLine(
      'This won’t take long—just a few steps to a cleaner project! 🚀\n');
  console.resetColorAttributes();

  // Proceed with the main CLI logic
  final directorySelector = DirectorySelector();
  final logRemovalManager = LogRemovalManager(directorySelector);

  // Heading for the next section
  console.setForegroundColor(ConsoleColor.brightYellow);
  console.writeLine("🌟 Let's get started with the clean-up! 🌟\n");
  console.resetColorAttributes();

  logRemovalManager.run();

  // End with a cheerful goodbye message
  console.setForegroundColor(ConsoleColor.brightMagenta);
  console.writeLine('\n✨ All done! Your project is squeaky clean now. ✨');
  console
      .writeLine('👋 Thanks for using Log Removal CLI. See you next time!\n');

  // Add some extra spacing and a final cheerful border
  console.setForegroundColor(ConsoleColor.cyan);
  console.writeLine("========================================");
  console.resetColorAttributes();
}
