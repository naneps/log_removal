# Deployment Guide: Publishing to pub.dev

This guide outlines the steps to publish the `log_removal` package to [pub.dev](https://pub.dev).

## 📋 Pre-publishing Checklist

Before publishing, ensure you have completed the following:

1.  **Run Tests**: Ensure all tests pass.
    ```bash
    dart test
    ```
2.  **Verify Version**: Ensure the version in `pubspec.yaml` and `CHANGELOG.md` is correct (e.g., `1.3.0`).
3.  **Check Formatting**: Ensure all files are correctly formatted.
    ```bash
    dart format .
    ```
4.  **Static Analysis**: Ensure there are no lint warnings or errors.
    ```bash
    dart analyze
    ```
5.  **Dry Run**: Perform a dry run of the publishing process to catch any issues.
    ```bash
    dart pub publish --dry-run
    ```

## 🚀 Publishing to pub.dev

Once you've verified everything, run the following command to publish:

```bash
dart pub publish
```

Follow the prompts in your terminal to complete the authentication and publishing process.

---

## 🏗️ Managing the VS Code Extension

Since the VS Code extension is in the same repository, you can package and publish it separately using `vsce`:

1.  **Install vsce**: `npm install -g @vscode/vsce`
2.  **Login**: `vsce login <publisher-name>`
3.  **Package**: `vsce package`
4.  **Publish**: `vsce publish`
