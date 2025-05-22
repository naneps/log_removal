# Dart Log Remover

## Description

Quickly remove `print()` and `dart:developer log()` statements from your Dart code. This extension helps clean up your codebase by removing debugging logs before committing or publishing your code.

## Features

*   **Remove Log Statements:** Deletes all found `print(...);` and `log(...);` statements from the currently active Dart file.
*   **Dry-run Mode:** Preview which log statements would be removed without actually modifying the file. The list of logs is shown in an Output Channel.
*   **Supported Log Types:**
    *   `print(...);` statements.
    *   `log(...);` statements from the `dart:developer` package.

## Installation

Currently, this extension is intended for local development and testing. To use it:

1.  **Clone the repository** (or ensure you have the source code).
2.  **Install dependencies:** Open the project folder in your terminal and run `npm install`.
3.  **Compile the extension:** Run `npm run compile` (or `npm run watch` for automatic compilation on changes).
4.  **Open in VS Code:** Open the extension's project folder in VS Code.
5.  **Run the Extension (Development Host):**
    *   Press `F5` or go to "Run" -> "Start Debugging". This will open a new VS Code window (the "Extension Development Host") with the extension loaded.
    *   Open any Dart project or file in this new window to test the extension.

Alternatively, to install it more permanently for local use (sideloading):

1.  **Package the extension:**
    *   You'll need the `vsce` (Visual Studio Code Extensions) packaging tool. If you don't have it, install it globally: `npm install -g vsce`
    *   In the root directory of the extension project, run: `vsce package`
    *   This will create a `.vsix` file (e.g., `dart-log-remover-0.0.1.vsix`).
2.  **Install from VSIX:**
    *   In VS Code, open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
    *   Type "Extensions: Install from VSIX..." and select it.
    *   Locate the `.vsix` file you created and select it.
    *   Reload VS Code when prompted.

## Usage

### Remove Log Statements

1.  Open a Dart file (`.dart`) in VS Code.
2.  Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
3.  Type "Remove Log Statements" and select the command `Dart Log Remover: Remove Log Statements`.
4.  If log statements are found, they will be removed from the file. An information message will confirm the number of statements removed.

### Dry-run: Show Logs to be Removed

1.  Open a Dart file (`.dart`) in VS Code.
2.  Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
3.  Type "Dry-run: Show Logs to be Removed" and select the command `Dart Log Remover: Dry-run: Show Logs to be Removed`.
4.  The extension will scan the file for log statements.
5.  The results will be displayed in the Output panel, under a channel named "Dart Log Remover". An information message will also appear, indicating how many potential logs were found.

## Known Issues/Limitations

*   **Regex-Based Matching:** The current implementation uses regular expressions to identify log statements. While designed to cover common cases, it may not perfectly handle all complex or unusually formatted multiline log statements. For example, a `print` statement where the closing `);` is on a much later line and involves complex string concatenation might not be fully captured.
*   **No Configuration:** There are currently no settings to customize which types of logs are removed (e.g., only `print`, or only `log`).

## Contributing

Contributions are welcome! If you have suggestions for improvements or find any issues, please feel free to open an issue or submit a pull request on the project's repository.

---

_This README was generated for the Dart Log Remover VS Code extension._
