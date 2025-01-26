
---

# Log Removal

🔧 **Log Removal** is a command-line tool for cleaning up Dart/Flutter projects from unwanted logs such as `print`, `debugPrint`, `logger`, and other custom log patterns.

This tool allows users to select which log patterns they want to remove, either by using predefined patterns or adding their own custom patterns. It can be installed globally for easy access across multiple projects.

---

## Key Features

- **Global Usage**: Install once and use across all your Dart/Flutter projects.
- **Multi-select**: Choose multiple log patterns to remove.
- **Custom Patterns**: Add custom log patterns using regular expressions (regex).
- **Compatibility**: Specifically designed for Dart and Flutter projects.
- **Ease of Use**: A simple text-based interface to select files or folders to be processed.

---

## Installation

### Global Installation

To install **Log Removal** globally, run the following command:

```bash
dart pub global activate log_removal_cli
```

Once installed globally, you can use `log_removal` in any Dart/Flutter project without needing to install it individually for each project.

### Local Installation

To use **Log Removal** in a specific project, add it as a dependency in your Dart/Flutter project by running:

```yaml
dependencies:
  log_removal: <latest_version>
```

Then, run it using the `dart run` command in your project.

---

## Usage

### Running the Program

After installation (either globally or locally), run the program with:

```bash
dart run log_removal
```

### Select an Operation

You will be prompted to choose one of the following options:
- Select a specific file to clean.
- Select a specific folder to clean.
- Clean the entire project.

### Select Log Patterns

You’ll be presented with a list of log patterns to remove:
- `print(...)`
- `debugPrint(...)`
- `logger.*(...)`
- `logMessage(...)`

You can select multiple patterns or add a custom pattern.

### Log Cleaning Process

After selecting the patterns, the program will process the chosen files and remove any lines that match the selected patterns. Once done, you’ll be shown the result of the cleaning and how many files were processed.

---

## Example

### Running the CLI

```bash
$ dart run log_removal_cli
🔧 Welcome to Log Removal!
Let's clean up your project from unwanted logs. 🚀

📂 Select a folder from the current directory:
✅ Folder selected: /path/to/project

Choose log patterns to remove:
[0] print(...)
[1] debugPrint(...)
[2] logger.*(...)
[3] logMessage(...)
[4] Custom pattern
Select options (e.g., 0,1,3): 0,1,4

🔧 Enter your custom regex pattern:
^\s*customLog\(.*\);\s*$
✅ Custom pattern added.

✅ Log removal completed.
📁 Files Processed: 5
```

---

## Log Pattern Configuration

The default log patterns available for selection are:

1. **`print(...)`**: Matches `print()` statements.
2. **`debugPrint(...)`**: Matches `debugPrint()` statements.
3. **`logger.*(...)`**: Matches logging functions like `logger.d()` or `logger.e()`.
4. **`logMessage(...)`**: Matches custom log functions like `logMessage()`.

In addition to the predefined patterns, you can add your custom log patterns using regex.

---

## Contributing

If you’re interested in contributing to this project, you can start by forking this repository and submitting a pull request. Make sure to review the code and follow good coding practices.

---

