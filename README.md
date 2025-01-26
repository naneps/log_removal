
---

# 🔧 Log Removal  

**Log Removal** is a command-line tool designed to clean up Dart/Flutter projects by removing unwanted log statements, such as `print`, `debugPrint`, `logger`, and other custom log patterns.  

This tool allows users to select predefined log patterns or add their custom patterns using regular expressions (regex). It can be installed globally for seamless usage across multiple projects.  

---

## ✨ Key Features  

- **Global Usage**: Install once and use it in all your Dart/Flutter projects.  
- **Multi-select**: Remove multiple log patterns in one go.  
- **Custom Patterns**: Add custom log patterns with regex.  
- **High Compatibility**: Specifically built for Dart and Flutter projects.  
- **User-Friendly**: A simple text-based interface to select files or folders for processing.  

---

## ⚙️ Installation  

### 1. Global Installation  

Install **Log Removal** globally to use it across all your projects with the following command:  

```bash
dart pub global activate log_removal
```  

After installation, the `log_removal` command will be available globally in your terminal, ready to use in any project directory.  

### 2. Local Installation (Optional)  

If you want to use **Log Removal** in a specific project, add it as a dependency:  

```yaml
dependencies:
  log_removal: <latest_version>
```  

Then, run it using the following command within the project:  

```bash
dart run log_removal
```  

---

## 🚀 How to Use  

### 1. Running the Program  

Once installed, run the program with:  

```bash
log_removal
```  

### 2. Select an Operation  

Choose one of the following options:  
- **Specific File**: Clean logs from a specific file.  
- **Specific Folder**: Clean logs from a specific folder.  
- **Entire Project**: Clean logs from the entire project.  

### 3. Choose Log Patterns  

The program will display a list of log patterns to remove, such as:  
- `print(...)`  
- `debugPrint(...)`  
- `logger.*(...)`  
- `logMessage(...)`  

You can select multiple patterns or add a custom pattern using regex.  

### 4. Cleaning Results  

After processing, the program will display:  
- The number of files processed.  
- The number of logs removed.  

---

## 📂 Example  

### Running the CLI  

```bash
$ log_removal
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

## 🛠 Supported Log Patterns  

The predefined log patterns include:  
1. **`print(...)`**: Matches `print()` statements.  
2. **`debugPrint(...)`**: Matches `debugPrint()` statements.  
3. **`logger.*(...)`**: Matches logging functions like `logger.d()` or `logger.e()`.  
4. **`logMessage(...)`**: Matches custom log functions like `logMessage()`.  

In addition to these, you can add custom log patterns using regex to handle unique logging formats in your projects.  

---

## 🤝 Contributing  

Contributions are welcome!  
To contribute:  
1. **Fork** this repository.  
2. Create a new branch for your feature or fix.  
3. Submit a pull request with a clear description of your changes.  

---

## 📄 License  

This project is licensed under the [MIT License](LICENSE).  

---  

This version is cleaner, more concise, and user-friendly. 🎉