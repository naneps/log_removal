import * as vscode from 'vscode';

// Regular expression to find 'print(...);' statements.
// This regex handles:
// - Optional whitespace before 'print'
// - 'print' keyword
// - Optional whitespace after 'print'
// - Opening parenthesis '('
// - Any characters inside the parentheses (non-greedy match)
// - Closing parenthesis ')'
// - Optional whitespace before semicolon
// - Semicolon ';'
// - Captures the entire line.
export const PRINT_LOG_REGEX = /^\s*print\s*\([\s\S]*?\)\s*;\s*$/gm;

// Regular expression to find 'log(...);' statements from dart:developer.
// This regex handles:
// - Optional whitespace before 'log'
// - 'log' keyword
// - Optional whitespace after 'log'
// - Opening parenthesis '('
// - Any characters inside the parentheses (non-greedy match)
// - Closing parenthesis ')'
// - Optional whitespace before semicolon
// - Semicolon ';'
// - Captures the entire line.
export const LOG_FUNCTION_REGEX = /^\s*log\s*\([\s\S]*?\)\s*;\s*$/gm;

export function activate(context: vscode.ExtensionContext) {
  console.log('Congratulations, your extension "dart-log-remover" is now active!');

  let disposable = vscode.commands.registerCommand('dart-log-remover.removeLogs', () => {
    const editor = vscode.window.activeTextEditor;

    if (!editor) {
      vscode.window.showInformationMessage('No active text editor found.');
      return;
    }

    const document = editor.document;
    const documentText = document.getText();
    let edits: vscode.TextEdit[] = [];
    let matchesFound = 0;

    // Combine regexes for a single pass, or iterate twice
    const combinedRegex = new RegExp(
      `(${PRINT_LOG_REGEX.source})|(${LOG_FUNCTION_REGEX.source})`,
      'gm'
    );

    let match;
    while ((match = combinedRegex.exec(documentText)) !== null) {
      const matchIndex = match.index;
      const startPosition = document.positionAt(matchIndex);
      const endPosition = document.positionAt(matchIndex + match[0].length);
      const range = new vscode.Range(startPosition, endPosition);
      
      // To remove the entire line, we extend the range to include the line break.
      // However, be careful not to remove the line break of the *next* line if the log is the last content on its line.
      // It's generally safer to just remove the matched text itself, 
      // but if the goal is to remove the whole line, we need to find the line's full range.
      const line = document.lineAt(startPosition.line);
      
      // Check if the match is the only content on the line (ignoring whitespace)
      if (line.text.trim() === match[0].trim()) {
        // If it's the only content, remove the whole line including the line break
        const lineEndPosition = document.lineAt(startPosition.line).range.end;
        // If it's not the last line, extend to the start of the next line to remove the line break
        if (startPosition.line < document.lineCount - 1) {
          edits.push(vscode.TextEdit.delete(new vscode.Range(line.range.start, document.lineAt(startPosition.line + 1).range.start)));
        } else {
          // If it's the last line, just delete the line content
          edits.push(vscode.TextEdit.delete(line.range));
        }
      } else {
        // If there's other content on the line, just delete the match
        edits.push(vscode.TextEdit.delete(range));
      }
      matchesFound++;
    }

    if (matchesFound === 0) {
      vscode.window.showInformationMessage('No Dart log statements found to remove.');
      return;
    }

    editor.edit(editBuilder => {
      edits.forEach(edit => editBuilder.delete(edit.range)); // editBuilder.replace(edit.range, edit.newText) if we were replacing
    }).then(success => {
      if (success) {
        vscode.window.showInformationMessage(`Removed ${matchesFound} log statement(s).`);
      } else {
        vscode.window.showErrorMessage('Failed to remove log statements.');
      }
    });
  });

  context.subscriptions.push(disposable);

  let dryRunDisposable = vscode.commands.registerCommand('dart-log-remover.dryRunRemoveLogs', () => {
    const editor = vscode.window.activeTextEditor;

    if (!editor) {
      vscode.window.showInformationMessage('No active text editor found.');
      return;
    }

    const document = editor.document;
    const documentText = document.getText();
    let logsFound: { lineNumber: number, content: string }[] = [];

    const combinedRegex = new RegExp(
      `(${PRINT_LOG_REGEX.source})|(${LOG_FUNCTION_REGEX.source})`,
      'gm'
    );

    let match;
    while ((match = combinedRegex.exec(documentText)) !== null) {
      const matchIndex = match.index;
      const startPosition = document.positionAt(matchIndex);
      const line = document.lineAt(startPosition.line);
      logsFound.push({ lineNumber: line.lineNumber + 1, content: line.text.trim() });
    }

    const outputChannel = vscode.window.createOutputChannel("Dart Log Remover");
    outputChannel.clear(); // Clear previous dry-run results

    if (logsFound.length === 0) {
      outputChannel.appendLine('No Dart log statements found.');
      vscode.window.showInformationMessage('No Dart log statements found to remove.');
    } else {
      outputChannel.appendLine(`Found ${logsFound.length} log statement(s) that would be removed:\n`);
      logsFound.forEach(log => {
        outputChannel.appendLine(`Line ${log.lineNumber}: ${log.content}`);
      });
      vscode.window.showInformationMessage(`Found ${logsFound.length} log statement(s). See the "Dart Log Remover" output channel for details.`);
    }
    outputChannel.show(true); // true to preserve focus on the editor
  });

  context.subscriptions.push(dryRunDisposable);
}

export function deactivate() {}
