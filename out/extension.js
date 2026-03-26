"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.LOGGER_REGEX = exports.LOG_FUNCTION_REGEX = exports.DEBUG_PRINT_REGEX = exports.PRINT_LOG_REGEX = void 0;
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
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
exports.PRINT_LOG_REGEX = /\bprint\s*\([\s\S]*?\)\s*;/gm;
exports.DEBUG_PRINT_REGEX = /\bdebugPrint\s*\([\s\S]*?\)\s*;/gm;
exports.LOG_FUNCTION_REGEX = /\blog\s*\([\s\S]*?\)\s*;/gm;
exports.LOGGER_REGEX = /\blogger\s*\([\s\S]*?\)\s*;/gm;
function activate(context) {
    console.log('Congratulations, your extension "dart-log-remover" is now active!');
    let disposable = vscode.commands.registerCommand('dart-log-remover.removeLogs', () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showInformationMessage('No active text editor found.');
            return;
        }
        const document = editor.document;
        const documentText = document.getText();
        let edits = [];
        let matchesFound = 0;
        // Combine regexes for a single pass, or iterate twice
        const combinedRegex = new RegExp(`(${exports.PRINT_LOG_REGEX.source})|(${exports.DEBUG_PRINT_REGEX.source})|(${exports.LOG_FUNCTION_REGEX.source})|(${exports.LOGGER_REGEX.source})`, 'gm');
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
                }
                else {
                    // If it's the last line, just delete the line content
                    edits.push(vscode.TextEdit.delete(line.range));
                }
            }
            else {
                // If there's other content on the line, just delete the match
                edits.push(vscode.TextEdit.delete(range));
            }
            matchesFound++;
        }
        if (matchesFound === 0) {
            vscode.window.showInformationMessage('No Dart log statements found to remove.');
            return;
        }
        editor.edit((editBuilder) => {
            edits.forEach(edit => editBuilder.delete(edit.range)); // editBuilder.replace(edit.range, edit.newText) if we were replacing
        }).then((success) => {
            if (success) {
                vscode.window.showInformationMessage(`Removed ${matchesFound} log statement(s).`);
            }
            else {
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
        let logsFound = [];
        const combinedRegex = new RegExp(`(${exports.PRINT_LOG_REGEX.source})|(${exports.DEBUG_PRINT_REGEX.source})|(${exports.LOG_FUNCTION_REGEX.source})|(${exports.LOGGER_REGEX.source})`, 'gm');
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
        }
        else {
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
function deactivate() { }
//# sourceMappingURL=extension.js.map