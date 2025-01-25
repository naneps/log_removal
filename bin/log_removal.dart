import 'dart:io';

import 'package:interact/interact.dart';
import 'package:log_removal/core/directory_selector.dart';
import 'package:log_removal/core/log_removal.dart';
import 'package:log_removal/models/pattern.dart';

void main() {
  print('🔧 Welcome to Log Removal CLI!');
  print('Let\'s clean up your project from unwanted logs. 🚀\n');

  final selector = DirectorySelector();
  final choice = selector.selectOperation();

  String targetPath;

  switch (choice) {
    case OperationType.specificFile:
      print('\n📂 Select a file from the current directory:');
      targetPath = selector.selectPath(showFiles: true);
      print('✅ File selected: $targetPath');
      break;

    case OperationType.specificFolder:
      print('\n📂 Select a folder from the current directory:');
      targetPath = selector.selectPath(showFiles: false);
      print('✅ Folder selected: $targetPath');
      break;

    case OperationType.entireProject:
      targetPath = Directory.current.path;
      print('📂 Targeting the entire project: $targetPath');
      break;

    default:
      print('❌ Invalid choice. Exiting...');
      return;
  }

  // Step 1: Define default patterns
  final defaultPatterns = <LogPattern>[
    LogPattern(name: 'print() statements', pattern: 'print\\(.*\\);'),
    LogPattern(name: 'debugPrint() statements', pattern: 'debugPrint\\(.*\\);'),
    LogPattern(name: 'log() statements', pattern: 'log\\(.*\\);'),
    LogPattern(name: 'logger() statements', pattern: 'logger\\(.*\\);'),
  ];

  // Step 2: Initialize MultiSelect for log patterns
  final multiSelect = MultiSelect(
    prompt: 'Choose log patterns to remove:',
    options: defaultPatterns.map((pattern) => pattern.name).toList(),
  ).interact();

  final selectedIndices = multiSelect;
  if (selectedIndices.isEmpty) {
    print('❌ No patterns selected. Exiting...');
    return;
  }

  // Step 3: Collect patterns based on user's selection
  final selectedPatterns = <RegExp>[];
  for (final index in selectedIndices) {
    if (index < defaultPatterns.length) {
      selectedPatterns.add(defaultPatterns[index].pattern);
    } else {
      print('\n🔧 Enter your custom regex pattern:');
      final customPatternInput = stdin.readLineSync();
      if (customPatternInput != null && customPatternInput.isNotEmpty) {
        try {
          selectedPatterns.add(RegExp(customPatternInput));
          print('✅ Custom pattern added.');
        } catch (e) {
          print('❌ Invalid regex pattern: $e');
        }
      }
    }
  }

  if (selectedPatterns.isEmpty) {
    print('❌ No valid patterns provided. Exiting...');
    return;
  }

  // Step 4: Initialize LogRemoval with selected patterns
  final logRemoval = LogRemoval(targetPath, logPatterns: selectedPatterns);

  try {
    final result = logRemoval.run();
    print('\n✅ ${result.message}');
    print('📁 Files Processed: ${result.filesProcessed}');
  } catch (e) {
    print('❌ Error: ${e.toString()}');
  }
}
